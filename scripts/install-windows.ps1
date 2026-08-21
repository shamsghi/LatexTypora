[CmdletBinding()]
param(
    [string]$ThemeDir = $env:TYPORA_THEME_DIR,
    [string]$Ref = $(if ($env:LATEX_TYPORA_REF) { $env:LATEX_TYPORA_REF } else { 'main' }),
    [switch]$NoPrune,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ManifestName = '.latex-typora-manifest'
$RepoOwner = 'shamsghi'
$RepoName = 'LatexTypora'
$TempDir = $null
$CreatedThemeDir = $false
$SourceDir = $null
$ResolvedThemeDir = $null

function Show-Usage {
    @"
Usage:
  .\scripts\install-windows.ps1 [-ThemeDir PATH] [-Ref REF] [-NoPrune]
  powershell -ExecutionPolicy Bypass -NoProfile -Command "irm https://raw.githubusercontent.com/$RepoOwner/$RepoName/main/scripts/install-windows.ps1 | iex"

Options:
  -ThemeDir PATH  Install into a specific Typora theme directory.
  -Ref REF        Install a specific branch, tag, or commit. Default: $Ref
  -NoPrune        Keep theme files this version no longer ships.
  -Help           Show this help message.

Environment:
  TYPORA_THEME_DIR  Same as -ThemeDir.
  LATEX_TYPORA_REF  Same as -Ref.
"@
}

if ($Help) {
    Show-Usage
    return
}

function Test-RepoCheckout {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Candidate
    )

    return (Test-Path -LiteralPath (Join-Path $Candidate 'latex.css') -PathType Leaf) `
        -and (Test-Path -LiteralPath (Join-Path $Candidate 'latex-dark.css') -PathType Leaf) `
        -and (Test-Path -LiteralPath (Join-Path $Candidate 'latex_fonts') -PathType Container)
}

function Resolve-LocalCheckoutRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$BaseDir
    )

    if (Test-RepoCheckout -Candidate $BaseDir) {
        return (Resolve-Path -LiteralPath $BaseDir).Path
    }

    $parentDir = Split-Path -Parent $BaseDir
    if ($parentDir -and (Test-RepoCheckout -Candidate $parentDir)) {
        return (Resolve-Path -LiteralPath $parentDir).Path
    }

    return $null
}

function Resolve-ThemeDir {
    if ($ThemeDir) {
        $script:ResolvedThemeDir = $ThemeDir
        return
    }

    $appData = [Environment]::GetFolderPath('ApplicationData')
    $officialDir = Join-Path (Join-Path $appData 'Typora') 'themes'

    if (Test-Path -LiteralPath $officialDir -PathType Container) {
        $script:ResolvedThemeDir = $officialDir
        return
    }

    $script:CreatedThemeDir = $true
    $script:ResolvedThemeDir = $officialDir
}

function Download-Source {
    $script:TempDir = Join-Path ([IO.Path]::GetTempPath()) ("LatexTypora-" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $script:TempDir | Out-Null

    $archivePath = Join-Path $script:TempDir 'theme.zip'
    $archiveUrl = "https://codeload.github.com/$RepoOwner/$RepoName/zip/$Ref"

    Write-Host "Downloading $RepoOwner/$RepoName@$Ref..."
    Invoke-WebRequest -Uri $archiveUrl -OutFile $archivePath
    Expand-Archive -LiteralPath $archivePath -DestinationPath $script:TempDir -Force

    $extractedDir = Get-ChildItem -LiteralPath $script:TempDir -Directory | Select-Object -First 1
    if (-not $extractedDir -or -not (Test-RepoCheckout -Candidate $extractedDir.FullName)) {
        throw 'Unable to find theme files in the downloaded archive.'
    }

    $script:SourceDir = $extractedDir.FullName
}

function Detect-SourceDir {
    $scriptDir = $PSScriptRoot

    if (-not $scriptDir -and $MyInvocation.MyCommand.Path) {
        $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }

    if ($scriptDir) {
        $checkoutRoot = Resolve-LocalCheckoutRoot -BaseDir $scriptDir
        if ($checkoutRoot) {
            $script:SourceDir = $checkoutRoot
            return
        }
    }

    Download-Source
}

function Test-OwnedPath {
    # Only ever consider paths this installer writes, and never a user's
    # own <theme>.user.css overrides.
    param([Parameter(Mandatory = $true)][string]$RelPath)

    if ($RelPath -match '\.\.' -or [System.IO.Path]::IsPathRooted($RelPath)) { return $false }
    if ($RelPath -like '*.user.css') { return $false }
    if ($RelPath -like 'latex_fonts/*.otf' -or $RelPath -like 'latex_fonts/*.ttf') { return $true }
    if ($RelPath -like 'latex*.css' -and $RelPath -notlike '*/*') { return $true }
    return $false
}

function Remove-StaleThemeFile {
    # Copying alone never removes anything, so a font this version dropped
    # would sit in the theme folder for good. Compare what the last run
    # recorded, plus whatever fonts are in our own directory, against what
    # we just installed.
    param(
        [Parameter(Mandatory = $true)][string]$ThemeDir,
        [Parameter(Mandatory = $true)][AllowEmptyCollection()][string[]]$Installed
    )

    $manifest = Join-Path $ThemeDir $ManifestName
    $candidates = New-Object System.Collections.Generic.List[string]

    if (Test-Path -LiteralPath $manifest) {
        foreach ($line in (Get-Content -LiteralPath $manifest)) {
            if ($line.Trim()) { $candidates.Add($line.Trim()) }
        }
    }
    $fontDir = Join-Path $ThemeDir 'latex_fonts'
    if (Test-Path -LiteralPath $fontDir) {
        foreach ($f in (Get-ChildItem -LiteralPath $fontDir -File | Where-Object { $_.Extension -in '.otf', '.ttf' })) {
            $candidates.Add("latex_fonts/$($f.Name)")
        }
    }

    $removed = 0
    foreach ($rel in ($candidates | Select-Object -Unique)) {
        if (-not (Test-OwnedPath -RelPath $rel)) { continue }
        if ($Installed -contains $rel) { continue }
        $full = Join-Path $ThemeDir $rel
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { continue }
        if ($NoPrune) {
            Write-Host "  Stale $rel kept (-NoPrune)"
        }
        else {
            Remove-Item -LiteralPath $full -Force
            Write-Host "  Removed stale $rel"
            $removed++
        }
    }
    if ($removed -gt 0) {
        Write-Host "  Removed $removed file(s) this version no longer ships"
    }
}

function Install-Theme {
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDir,
        [Parameter(Mandatory = $true)]
        [string]$ThemeDir
    )

    $fontDir = Join-Path $ThemeDir 'latex_fonts'

    New-Item -ItemType Directory -Path $ThemeDir -Force | Out-Null
    New-Item -ItemType Directory -Path $fontDir -Force | Out-Null

    Copy-Item -Path (Join-Path $SourceDir 'latex*.css') -Destination $ThemeDir -Force
    Copy-Item -Path (Join-Path $SourceDir 'latex_fonts\*.otf') -Destination $fontDir -Force
    Copy-Item -Path (Join-Path $SourceDir 'latex_fonts\*.ttf') -Destination $fontDir -Force

    $installed = New-Object System.Collections.Generic.List[string]
    foreach ($f in Get-ChildItem -LiteralPath $SourceDir -File -Filter 'latex*.css') {
        $installed.Add($f.Name)
    }
    foreach ($f in (Get-ChildItem -LiteralPath (Join-Path $SourceDir 'latex_fonts') -File | Where-Object { $_.Extension -in '.otf', '.ttf' })) {
        $installed.Add("latex_fonts/$($f.Name)")
    }

    Remove-StaleThemeFile -ThemeDir $ThemeDir -Installed $installed.ToArray()
    $installed | Sort-Object | Set-Content -LiteralPath (Join-Path $ThemeDir $ManifestName) -Encoding UTF8
}

try {
    Detect-SourceDir
    Resolve-ThemeDir

    Write-Host "Installing LaTeX Typora theme files into:"
    Write-Host "  $ResolvedThemeDir"

    Install-Theme -SourceDir $SourceDir -ThemeDir $ResolvedThemeDir

    Write-Host ''
    Write-Host 'Installed files:'
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex.css')"
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex-dark.css')"
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex-dev-dark.css')"
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex_fonts\*.otf')"
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex_fonts\*.ttf')"

    if ($CreatedThemeDir) {
        Write-Host ''
        Write-Host 'Created the default Typora theme directory because it did not already exist.'
        Write-Host 'If your Typora install uses a different theme folder, rerun with:'
        Write-Host '  .\scripts\install-windows.ps1 -ThemeDir "C:\path\to\Typora\themes"'
    }

    Write-Host ''
    Write-Host 'Restart Typora or switch to latex / latex-dark / latex-dev-dark from the Themes menu.'
}
finally {
    if ($TempDir -and (Test-Path -LiteralPath $TempDir)) {
        Remove-Item -LiteralPath $TempDir -Recurse -Force
    }
}
