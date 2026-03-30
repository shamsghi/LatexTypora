[CmdletBinding()]
param(
    [string]$ThemeDir = $env:TYPORA_THEME_DIR,
    [string]$Ref = $(if ($env:LATEX_TYPORA_REF) { $env:LATEX_TYPORA_REF } else { 'main' }),
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoOwner = 'shamsghi'
$RepoName = 'LatexTypora'
$TempDir = $null
$CreatedThemeDir = $false
$SourceDir = $null
$ResolvedThemeDir = $null

function Show-Usage {
    @"
Usage:
  .\scripts\install-windows.ps1 [-ThemeDir PATH] [-Ref REF]
  powershell -ExecutionPolicy Bypass -NoProfile -Command "irm https://raw.githubusercontent.com/$RepoOwner/$RepoName/main/scripts/install-windows.ps1 | iex"

Options:
  -ThemeDir PATH  Install into a specific Typora theme directory.
  -Ref REF        Install a specific branch, tag, or commit. Default: $Ref
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

    Copy-Item -LiteralPath (Join-Path $SourceDir 'latex.css') -Destination (Join-Path $ThemeDir 'latex.css') -Force
    Copy-Item -LiteralPath (Join-Path $SourceDir 'latex-dark.css') -Destination (Join-Path $ThemeDir 'latex-dark.css') -Force
    Copy-Item -Path (Join-Path $SourceDir 'latex_fonts\*.woff') -Destination $fontDir -Force
}

try {
    Detect-SourceDir
    Resolve-ThemeDir

    Write-Host "Installing LatexTypora into:"
    Write-Host "  $ResolvedThemeDir"

    Install-Theme -SourceDir $SourceDir -ThemeDir $ResolvedThemeDir

    Write-Host ''
    Write-Host 'Installed files:'
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex.css')"
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex-dark.css')"
    Write-Host "  $(Join-Path $ResolvedThemeDir 'latex_fonts\*.woff')"

    if ($CreatedThemeDir) {
        Write-Host ''
        Write-Host 'Created the default Typora theme directory because it did not already exist.'
        Write-Host 'If your Typora install uses a different theme folder, rerun with:'
        Write-Host '  .\scripts\install-windows.ps1 -ThemeDir "C:\path\to\Typora\themes"'
    }

    Write-Host ''
    Write-Host 'Restart Typora or switch to the Latex / Latex Dark theme from Themes.'
}
finally {
    if ($TempDir -and (Test-Path -LiteralPath $TempDir)) {
        Remove-Item -LiteralPath $TempDir -Recurse -Force
    }
}
