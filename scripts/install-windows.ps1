[CmdletBinding()]
param(
    [string]$ThemeDir = $env:TYPORA_THEME_DIR,
    [string]$Ref = $(if ($env:LATEX_TYPORA_REF) { $env:LATEX_TYPORA_REF } else { 'main' }),
    [switch]$NoPrune,
    [switch]$NoAnim,
    [switch]$Plain,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

[string]$script:RepoOwner = 'shamsghi'
[string]$script:RepoName = 'LatexTypora'
[string]$script:ManifestName = '.latex-typora-manifest'
[string]$script:TempDir = ''
[string]$script:SourceDir = ''
[string]$script:ResolvedThemeDir = ''
[string]$script:InstallerScriptDirectory = $PSScriptRoot
[bool]$script:CreatedThemeDir = $false
[bool]$script:PruneEnabled = -not ($NoPrune.IsPresent -or $env:LATEX_TYPORA_NO_PRUNE -eq '1')
[bool]$script:PlainOutput = $Plain.IsPresent -or $env:LATEX_TYPORA_PLAIN -eq '1'
[bool]$script:ColorEnabled = $false
[bool]$script:AnimationEnabled = $false
[int]$script:CurrentStep = 0
[int]$script:TotalSteps = 5
[int]$script:ProgressLast = 0
[int]$script:FrameWidth = 76
[int]$script:FrameIndent = 0
[string]$script:FramePadding = ''
[string[]]$script:InstalledRelPaths = @()
[string[]]$script:InstalledThemes = @()
[int]$script:InstalledAssetCount = 0

function Show-Usage {
    @"
Usage:
  .\scripts\install-windows.ps1 [-ThemeDir PATH] [-Ref REF]
  irm https://raw.githubusercontent.com/$script:RepoOwner/$script:RepoName/main/scripts/install-windows.ps1 | iex

Options:
  -ThemeDir PATH  Install into a specific Typora theme directory.
  -Ref REF        Install a specific branch, tag, or commit. Default: $Ref
  -NoPrune        Keep theme files this version no longer ships.
  -NoAnim         Disable animated banner and progress output.
  -Plain          Disable colors and animations.
  -Help           Show this help message.

Environment:
  TYPORA_THEME_DIR             Same as -ThemeDir.
  LATEX_TYPORA_REF             Same as -Ref.
  LATEX_TYPORA_NO_PRUNE        Set to 1 to keep stale theme files.
  LATEX_TYPORA_NO_ANIM         Set to 1 to disable animations.
  LATEX_TYPORA_NO_COLOR        Set to 1 to disable colors.
  NO_COLOR                     Standard variable to disable colors.
  LATEX_TYPORA_ANIMATION_DELAY Seconds between progress frames. Default: 0.012
  LATEX_TYPORA_TITLE_DELAY     Seconds between title lines. Default: 0.02
  LATEX_TYPORA_MAX_WIDTH       Widest the framed output may be drawn. Default: 76
"@
}

if ($Help.IsPresent) {
    Show-Usage
    return
}

function Get-EnvironmentDelayMilliseconds {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [double]$DefaultSeconds
    )

    [string]$configuredValue = [Environment]::GetEnvironmentVariable($Name)
    [double]$seconds = $DefaultSeconds
    [double]$parsedSeconds = 0
    if ($configuredValue -and [double]::TryParse(
            $configuredValue,
            [Globalization.NumberStyles]::Float,
            [Globalization.CultureInfo]::InvariantCulture,
            [ref]$parsedSeconds
        ) -and $parsedSeconds -ge 0) {
        $seconds = $parsedSeconds
    }
    return [Math]::Max(0, [int][Math]::Round($seconds * 1000))
}

function Initialize-Ui {
    [bool]$outputRedirected = $true
    try {
        $outputRedirected = [Console]::IsOutputRedirected
    }
    catch {
        $outputRedirected = $true
    }

    $script:ColorEnabled = (
        (-not $script:PlainOutput) -and
        (-not $outputRedirected) -and
        (-not $env:NO_COLOR) -and
        ($env:LATEX_TYPORA_NO_COLOR -ne '1')
    )
    $script:AnimationEnabled = (
        (-not $script:PlainOutput) -and
        (-not $outputRedirected) -and
        (-not $NoAnim.IsPresent) -and
        ($env:LATEX_TYPORA_NO_ANIM -ne '1') -and
        (-not $env:CI)
    )

    [int]$terminalWidth = 80
    try {
        if ([Console]::WindowWidth -gt 0) {
            $terminalWidth = [Console]::WindowWidth
        }
    }
    catch {
        $terminalWidth = 80
    }

    [int]$maxMeasure = 76
    [int]$parsedMaxMeasure = 0
    if (
        $env:LATEX_TYPORA_MAX_WIDTH -and
        [int]::TryParse($env:LATEX_TYPORA_MAX_WIDTH, [ref]$parsedMaxMeasure) -and
        $parsedMaxMeasure -ge 20
    ) {
        $maxMeasure = $parsedMaxMeasure
    }
    $script:FrameWidth = [Math]::Max(20, [Math]::Min($maxMeasure, $terminalWidth - 2))
    $script:FrameIndent = [Math]::Max(0, [int][Math]::Floor(($terminalWidth - $script:FrameWidth) / 2))
    $script:FramePadding = ' ' * $script:FrameIndent
}

function Write-UiText {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,
        [string]$Color = '',
        [switch]$NoNewline
    )

    [hashtable]$writeArguments = @{}
    if ($script:ColorEnabled -and $Color) {
        $writeArguments.ForegroundColor = $Color
    }
    if ($NoNewline.IsPresent) {
        $writeArguments.NoNewline = $true
    }
    Write-Host $Text @writeArguments
}

function Write-CenteredLine {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Text,
        [string]$Color = ''
    )

    [int]$padding = $script:FrameIndent + [Math]::Max(
        0,
        [int][Math]::Floor(($script:FrameWidth - $Text.Length) / 2)
    )
    Write-UiText -Text ((' ' * $padding) + $Text) -Color $Color
}

function Write-CenteredBlock {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$Lines,
        [string]$Color = '',
        [Parameter(Mandatory = $true)]
        [int]$LineDelayMilliseconds
    )

    [string[]]$trimmedLines = @($Lines | ForEach-Object { $_.TrimEnd() })
    [int]$blockWidth = 0
    foreach ($line in $trimmedLines) {
        if ($line.Length -gt $blockWidth) {
            $blockWidth = $line.Length
        }
    }
    [int]$padding = $script:FrameIndent + [Math]::Max(
        0,
        [int][Math]::Floor(($script:FrameWidth - $blockWidth) / 2)
    )
    foreach ($line in $trimmedLines) {
        Write-UiText -Text ((' ' * $padding) + $line) -Color $Color
        if ($script:AnimationEnabled -and $LineDelayMilliseconds -gt 0) {
            Start-Sleep -Milliseconds $LineDelayMilliseconds
        }
    }
}

function Write-Rule {
    param(
        [char]$Character = '=',
        [string]$Color = 'Blue'
    )

    Write-UiText -Text ($script:FramePadding + ([string]$Character * $script:FrameWidth)) -Color $Color
}

function Write-Banner {
    [int]$titleDelay = Get-EnvironmentDelayMilliseconds -Name 'LATEX_TYPORA_TITLE_DELAY' -DefaultSeconds 0.02
    [string[]]$latexLines = @()
    [string[]]$typoraLines = @()

    if ($script:FrameWidth -ge 60) {
        $latexLines = @(
            '      ooooo      o   ooooooooooooo       ooooooo  ooooo',
            "     ``888'     888  8'   888   ``8        ``8888    d8'",
            '     888     8  88      888  oooooooooooo Y888..8P',
            "     888    8oooo88     888  ``888'     ``8  ``8888'",
            '    888  o88o  o888o   888   888         .8PY888.',
            "   888       o        888   888oooo8   d8'  ``888b",
            ' o888ooooood8       o888o  888    " o888o  o88888o',
            '                           888       o',
            '                         o888ooooood8'
        )
        $typoraLines = @(
            '11188111',
            '"""88"""',
            '   88   ee      ee  eeeeeeee  eeeeeeee  eeeeeeee   eeeeeeee',
            '   88e  88      88  88    88  88    88  88    88   88    88',
            '   88e  88      88  88    88  88    88  88    88   88    88',
            '   888  88eeeeee88  88eeee88  88    88  88eeee88e  88eeee88',
            '   888     888      888       88    88  888     8  888   88',
            '   888     888      888       88    88  888     8  888   88',
            '   888     888      888       88eeee88  888     8  888   88'
        )
    }
    else {
        $latexLines = @(
            '8      88888     Yb  dP',
            '8   db   8  8888  YbdP',
            '8  dPYb  8  8www  dPYb',
            '8888     8  8    dP  Yb',
            '            8888'
        )
        $typoraLines = @(
            '88888',
            '  8   Yb  dP 88b. .d8b. 8d8b .d88',
            "  8    YbdP  8  8 8' .8 8P   8  8",
            '  8     dP   88P'' `Y8P'' 8    `Y88',
            '       dP    8'
        )
    }

    Write-Host ''
    Write-Rule -Character '=' -Color 'Blue'
    Write-CenteredBlock -Lines $latexLines -Color 'Blue' -LineDelayMilliseconds $titleDelay
    Write-Host ''
    Write-CenteredBlock -Lines $typoraLines -Color 'DarkGray' -LineDelayMilliseconds $titleDelay
    Write-Rule -Character '=' -Color 'Blue'
    Write-Host ''
}

function Write-Status {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Tag,
        [Parameter(Mandatory = $true)]
        [string]$Text,
        [string]$Color = ''
    )

    Write-UiText -Text ((' ' * ($script:FrameIndent + 2)) + ('{0,-4} ' -f $Tag)) -Color $Color -NoNewline
    Write-Host $Text
}

function Write-Info {
    param([Parameter(Mandatory = $true)][string]$Text)
    Write-Status -Tag '-' -Text $Text -Color 'Blue'
}

function Write-Success {
    param([Parameter(Mandatory = $true)][string]$Text)
    Write-Status -Tag '[ok]' -Text $Text -Color 'Blue'
}

function Write-InstallerWarning {
    param([Parameter(Mandatory = $true)][string]$Text)
    Write-Status -Tag '[!]' -Text $Text -Color 'Yellow'
}

function Write-Step {
    param([Parameter(Mandatory = $true)][string]$Text)

    $script:CurrentStep++
    [string]$stepText = '=> Step {0}/{1}: {2}' -f $script:CurrentStep, $script:TotalSteps, $Text
    Write-UiText -Text ($script:FramePadding + $stepText) -Color 'Blue'
}

function Get-ProgressText {
    param([Parameter(Mandatory = $true)][ValidateRange(0, 100)][int]$Percent)

    [int]$width = 28
    [int]$filled = [Math]::Min($width, [int][Math]::Floor($Percent * $width / 100))
    [int]$empty = $width - $filled
    [string]$gutter = ' ' * ($script:FrameIndent + 2)
    [string]$bar = '[{0}{1}] {2,3}%' -f ('=' * $filled), ('.' * $empty), $Percent
    return $gutter + $bar
}

function Write-ProgressTick {
    if ($script:PlainOutput) {
        return
    }

    [int]$targetPercent = [int][Math]::Floor($script:CurrentStep * 100 / $script:TotalSteps)
    [int]$animationDelay = Get-EnvironmentDelayMilliseconds -Name 'LATEX_TYPORA_ANIMATION_DELAY' -DefaultSeconds 0.012
    if ($script:AnimationEnabled) {
        [int]$framePercent = $script:ProgressLast + 4
        while ($framePercent -lt $targetPercent) {
            Write-UiText -Text ("`r" + (Get-ProgressText -Percent $framePercent)) -Color 'DarkGray' -NoNewline
            if ($animationDelay -gt 0) {
                Start-Sleep -Milliseconds $animationDelay
            }
            $framePercent += 4
        }
        Write-UiText -Text "`r" -NoNewline
    }
    Write-UiText -Text (Get-ProgressText -Percent $targetPercent) -Color 'DarkGray'
    $script:ProgressLast = $targetPercent
}

function Get-DisplayPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    [string]$userProfile = [Environment]::GetFolderPath('UserProfile')
    if ($userProfile -and $Path.StartsWith(
            $userProfile + [IO.Path]::DirectorySeparatorChar,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        return '~\' + $Path.Substring($userProfile.Length + 1)
    }
    return $Path
}

function Get-PluralText {
    param(
        [Parameter(Mandatory = $true)][int]$Count,
        [Parameter(Mandatory = $true)][string]$Word
    )

    if ($Count -eq 1) {
        return "$Count $Word"
    }
    return "$Count ${Word}s"
}

function Write-CompletionBlock {
    [string]$themeList = $script:InstalledThemes -join ', '
    Write-Host ''
    Write-Rule -Character '=' -Color 'Blue'
    Write-CenteredLine -Text 'INSTALLATION COMPLETE' -Color 'Blue'
    Write-CenteredLine -Text 'LaTeX Typora theme assets are installed.'
    Write-Rule -Character '-' -Color 'DarkGray'
    Write-Info -Text ('Installed to: ' + (Get-DisplayPath -Path $script:ResolvedThemeDir))
    Write-Info -Text "In Typora, choose a theme: $themeList."
    Write-Info -Text 'If the themes are missing, restart Typora.'
    Write-Rule -Character '=' -Color 'Blue'
}

function Assert-ValidRef {
    if (-not $Ref) {
        throw 'Ref cannot be empty.'
    }
    if ($Ref -match '[^A-Za-z0-9._/\-]' -or $Ref.Contains('..')) {
        throw "Invalid -Ref value '$Ref'. Use a branch, tag, or commit SHA."
    }
}

function Test-RepoCheckout {
    param([Parameter(Mandatory = $true)][string]$Candidate)

    return (
        (Test-Path -LiteralPath (Join-Path $Candidate 'latex.css') -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $Candidate 'latex-dark.css') -PathType Leaf) -and
        (Test-Path -LiteralPath (Join-Path $Candidate 'latex_fonts') -PathType Container)
    )
}

function Resolve-LocalCheckoutRoot {
    param([Parameter(Mandatory = $true)][string]$BaseDir)

    if (Test-RepoCheckout -Candidate $BaseDir) {
        return (Resolve-Path -LiteralPath $BaseDir).Path
    }
    [string]$parentDir = Split-Path -Parent $BaseDir
    if ($parentDir -and (Test-RepoCheckout -Candidate $parentDir)) {
        return (Resolve-Path -LiteralPath $parentDir).Path
    }
    return ''
}

function Resolve-ThemeDirectory {
    if ($ThemeDir) {
        $script:ResolvedThemeDir = $ThemeDir
        $script:CreatedThemeDir = -not (Test-Path -LiteralPath $ThemeDir -PathType Container)
        return
    }

    [string]$applicationData = [Environment]::GetFolderPath('ApplicationData')
    if (-not $applicationData) {
        throw 'Unable to resolve the Windows application-data directory. Pass -ThemeDir explicitly.'
    }
    $script:ResolvedThemeDir = Join-Path (Join-Path $applicationData 'Typora') 'themes'
    $script:CreatedThemeDir = -not (Test-Path -LiteralPath $script:ResolvedThemeDir -PathType Container)
}

function Download-Source {
    $script:TempDir = Join-Path ([IO.Path]::GetTempPath()) ('LatexTypora-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TempDir | Out-Null

    [string]$archivePath = Join-Path $script:TempDir 'theme.zip'
    [string]$archiveUrl = "https://codeload.github.com/$script:RepoOwner/$script:RepoName/zip/$Ref"

    [Net.ServicePointManager]::SecurityProtocol = (
        [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    )
    Invoke-WebRequest -UseBasicParsing -Uri $archiveUrl -OutFile $archivePath
    Write-Success -Text "Downloaded $script:RepoOwner/$script:RepoName@$Ref"
    Expand-Archive -LiteralPath $archivePath -DestinationPath $script:TempDir -Force
    Write-Success -Text 'Extracted source snapshot'

    [IO.DirectoryInfo[]]$extractedDirectories = @(Get-ChildItem -LiteralPath $script:TempDir -Directory)
    foreach ($directory in $extractedDirectories) {
        if (Test-RepoCheckout -Candidate $directory.FullName) {
            $script:SourceDir = $directory.FullName
            return
        }
    }
    throw 'Unable to find theme files in the downloaded archive.'
}

function Find-SourceDirectory {
    [string]$forwardedSourceDir = $env:LATEX_TYPORA_SOURCE_DIR
    if ($forwardedSourceDir) {
        if (-not (Test-RepoCheckout -Candidate $forwardedSourceDir)) {
            throw "The forwarded checkout '$forwardedSourceDir' does not contain the expected theme files."
        }
        $script:SourceDir = (Resolve-Path -LiteralPath $forwardedSourceDir).Path
        Write-Success -Text ('Using local checkout at ' + (Get-DisplayPath -Path $script:SourceDir))
        return
    }

    [string]$scriptDirectory = $script:InstallerScriptDirectory
    if ($scriptDirectory) {
        [string]$checkoutRoot = Resolve-LocalCheckoutRoot -BaseDir $scriptDirectory
        if ($checkoutRoot) {
            $script:SourceDir = $checkoutRoot
            Write-Success -Text ('Using local checkout at ' + (Get-DisplayPath -Path $script:SourceDir))
            return
        }
    }

    Download-Source
}

function Test-OwnedPath {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    if ($RelativePath.Contains('..') -or [IO.Path]::IsPathRooted($RelativePath)) {
        return $false
    }
    if ($RelativePath -like '*.user.css') {
        return $false
    }
    if ($RelativePath -match '^latex_fonts/[^/]+\.(otf|ttf|css)$') {
        return $true
    }
    return $RelativePath -match '^latex[^/]*\.css$'
}

function Remove-StaleThemeFiles {
    param(
        [Parameter(Mandatory = $true)][string]$TargetThemeDir,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$InstalledPaths
    )

    [Collections.Generic.HashSet[string]]$installedSet = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )
    foreach ($installedPath in $InstalledPaths) {
        [void]$installedSet.Add($installedPath)
    }

    [Collections.Generic.HashSet[string]]$candidates = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::OrdinalIgnoreCase
    )
    [string]$manifestPath = Join-Path $TargetThemeDir $script:ManifestName
    if (Test-Path -LiteralPath $manifestPath -PathType Leaf) {
        foreach ($line in (Get-Content -LiteralPath $manifestPath)) {
            [string]$trimmedLine = $line.Trim()
            if ($trimmedLine) {
                [void]$candidates.Add($trimmedLine)
            }
        }
    }

    [string]$fontDir = Join-Path $TargetThemeDir 'latex_fonts'
    if (Test-Path -LiteralPath $fontDir -PathType Container) {
        [IO.FileInfo[]]$existingFontAssets = @(
            Get-ChildItem -LiteralPath $fontDir -File |
                Where-Object { $_.Extension.ToLowerInvariant() -in @('.otf', '.ttf', '.css') }
        )
        foreach ($fontAsset in $existingFontAssets) {
            [void]$candidates.Add("latex_fonts/$($fontAsset.Name)")
        }
    }

    [int]$removedCount = 0
    foreach ($relativePath in $candidates) {
        if (-not (Test-OwnedPath -RelativePath $relativePath) -or $installedSet.Contains($relativePath)) {
            continue
        }
        [string]$fullPath = Join-Path $TargetThemeDir $relativePath
        if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
            continue
        }
        if ($script:PruneEnabled) {
            Remove-Item -LiteralPath $fullPath -Force
            Write-Info -Text "Removed stale $relativePath"
            $removedCount++
        }
        else {
            Write-InstallerWarning -Text "Stale $relativePath kept (-NoPrune)"
        }
    }
    if ($removedCount -gt 0) {
        Write-Success -Text "Removed $removedCount file(s) this version no longer ships"
    }
}

function Write-Manifest {
    param(
        [Parameter(Mandatory = $true)][string]$TargetThemeDir,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$InstalledPaths
    )

    [string[]]$sortedPaths = @($InstalledPaths | Sort-Object -Unique)
    [Text.UTF8Encoding]$utf8WithoutBom = [Text.UTF8Encoding]::new($false)
    [string]$manifestContent = [string]::Join("`n", $sortedPaths) + "`n"
    [IO.File]::WriteAllText(
        (Join-Path $TargetThemeDir $script:ManifestName),
        $manifestContent,
        $utf8WithoutBom
    )
}

function Install-Theme {
    param(
        [Parameter(Mandatory = $true)][string]$InstallSourceDir,
        [Parameter(Mandatory = $true)][string]$TargetThemeDir
    )

    [string]$sourceFontDir = Join-Path $InstallSourceDir 'latex_fonts'
    [string]$targetFontDir = Join-Path $TargetThemeDir 'latex_fonts'
    [IO.FileInfo[]]$cssFiles = @(Get-ChildItem -LiteralPath $InstallSourceDir -File -Filter 'latex*.css')
    [IO.FileInfo[]]$fontFiles = @(
        Get-ChildItem -LiteralPath $sourceFontDir -File |
            Where-Object { $_.Extension.ToLowerInvariant() -in @('.otf', '.ttf', '.css') }
    )
    if ($cssFiles.Count -eq 0) {
        throw 'No latex*.css theme files found in source.'
    }
    if ($fontFiles.Count -eq 0) {
        throw 'No font files found in source.'
    }

    New-Item -ItemType Directory -Path $TargetThemeDir -Force | Out-Null
    New-Item -ItemType Directory -Path $targetFontDir -Force | Out-Null
    foreach ($cssFile in $cssFiles) {
        Copy-Item -LiteralPath $cssFile.FullName -Destination $TargetThemeDir -Force
    }
    Write-Success -Text 'Copied latex*.css files'
    foreach ($fontFile in $fontFiles) {
        Copy-Item -LiteralPath $fontFile.FullName -Destination $targetFontDir -Force
    }
    Write-Success -Text 'Copied latex_fonts files'

    [Collections.Generic.List[string]]$installedPaths = [Collections.Generic.List[string]]::new()
    foreach ($cssFile in $cssFiles) {
        [void]$installedPaths.Add($cssFile.Name)
    }
    foreach ($fontFile in $fontFiles) {
        [void]$installedPaths.Add("latex_fonts/$($fontFile.Name)")
    }
    $script:InstalledRelPaths = $installedPaths.ToArray()

    [string[]]$baseThemes = @(
        $cssFiles |
            Where-Object { $_.Name -notlike '*.user.css' -and $_.BaseName -notlike '*-*' } |
            ForEach-Object { $_.BaseName }
    )
    [string[]]$variantThemes = @(
        $cssFiles |
            Where-Object { $_.Name -notlike '*.user.css' -and $_.BaseName -like '*-*' } |
            ForEach-Object { $_.BaseName }
    )
    $script:InstalledThemes = @($baseThemes + $variantThemes)
    $script:InstalledAssetCount = $fontFiles.Count

    Remove-StaleThemeFiles -TargetThemeDir $TargetThemeDir -InstalledPaths $script:InstalledRelPaths
    Write-Manifest -TargetThemeDir $TargetThemeDir -InstalledPaths $script:InstalledRelPaths

    [string]$themeCount = Get-PluralText -Count $script:InstalledThemes.Count -Word 'theme'
    [string]$assetCount = Get-PluralText -Count $script:InstalledAssetCount -Word 'file'
    Write-Success -Text ('Installed {0}: {1}' -f $themeCount, ($script:InstalledThemes -join ', '))
    Write-Success -Text ('Installed {0} into latex_fonts/' -f $assetCount)
}

Initialize-Ui

try {
    Write-Banner

    Write-Step -Text 'Checking requirements'
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        throw 'PowerShell 5.0 or newer is required.'
    }
    Assert-ValidRef
    Write-Success -Text 'Required commands are available'
    Write-ProgressTick

    Write-Step -Text 'Detecting your platform'
    if ($env:OS -ne 'Windows_NT') {
        throw 'This installer requires Windows. Use scripts/install.sh on macOS or Linux.'
    }
    Write-Success -Text 'Detected platform: windows'
    Write-ProgressTick

    Write-Step -Text 'Locating installation source'
    Find-SourceDirectory
    Write-ProgressTick

    Write-Step -Text 'Resolving Typora theme directory'
    Resolve-ThemeDirectory
    Write-Info -Text ('Target directory: ' + (Get-DisplayPath -Path $script:ResolvedThemeDir))
    if ($script:CreatedThemeDir) {
        Write-InstallerWarning -Text 'Theme directory does not exist yet; installer will create it.'
    }
    Write-Success -Text 'Theme directory resolved'
    Write-ProgressTick

    Write-Step -Text 'Installing files'
    Install-Theme -InstallSourceDir $script:SourceDir -TargetThemeDir $script:ResolvedThemeDir
    Write-ProgressTick

    Write-CompletionBlock
}
finally {
    if ($script:TempDir -and (Test-Path -LiteralPath $script:TempDir -PathType Container)) {
        Remove-Item -LiteralPath $script:TempDir -Recurse -Force
    }
}
