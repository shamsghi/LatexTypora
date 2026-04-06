#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="shamsghi"
REPO_NAME="LatexTypora"
DEFAULT_REF="${LATEX_TYPORA_REF:-main}"

THEME_DIR="${TYPORA_THEME_DIR:-}"
REF="$DEFAULT_REF"
TEMP_DIR=""
SOURCE_DIR=""
RESOLVED_THEME_DIR=""
PLATFORM=""
CREATED_THEME_DIR=0

if [[ -t 1 ]]; then
    BOLD="\033[1m"
    RESET="\033[0m"
    BLUE="\033[34m"
    GREEN="\033[32m"
    YELLOW="\033[33m"
    RED="\033[31m"
else
    BOLD=""
    RESET=""
    BLUE=""
    GREEN=""
    YELLOW=""
    RED=""
fi

usage() {
    cat <<EOF
Usage:
  ./scripts/install.sh [--theme-dir PATH] [--ref REF]
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/scripts/install.sh | bash

Options:
  --theme-dir PATH  Install into a specific Typora theme directory.
  --ref REF         Install a specific branch, tag, or commit. Default: ${DEFAULT_REF}
  -h, --help        Show this help message.

Environment:
  TYPORA_THEME_DIR  Same as --theme-dir.
  LATEX_TYPORA_REF  Same as --ref.
EOF
}

print_banner() {
    printf '%b\n' "${BOLD}${BLUE}╔══════════════════════════════════════════════╗${RESET}"
    printf '%b\n' "${BOLD}${BLUE}║          LaTeX Typora Theme Installer        ║${RESET}"
    printf '%b\n' "${BOLD}${BLUE}╚══════════════════════════════════════════════╝${RESET}"
}

step() {
    printf '%b\n' "${BOLD}${BLUE}→${RESET} ${BOLD}$1${RESET}"
}

info() {
    printf '%b\n' "${BLUE}  •${RESET} $1"
}

success() {
    printf '%b\n' "${GREEN}  ✓${RESET} $1"
}

warn() {
    printf '%b\n' "${YELLOW}  !${RESET} $1"
}

die() {
    printf '%b\n' "${RED}  ✗ $1${RESET}" >&2
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --theme-dir)
            [[ $# -ge 2 ]] || die "Missing value for $1"
            THEME_DIR="$2"
            shift 2
            ;;
        --ref)
            [[ $# -ge 2 ]] || die "Missing value for $1"
            REF="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage >&2
            die "Unknown argument: $1"
            ;;
    esac
done

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        die "Missing required command: $1"
    fi
}

validate_ref() {
    if [[ -z "${REF}" ]]; then
        die "Ref cannot be empty."
    fi
    if [[ "${REF}" =~ [^A-Za-z0-9._/\-] ]] || [[ "${REF}" == *".."* ]]; then
        die "Invalid --ref value '${REF}'. Use a branch, tag, or commit SHA."
    fi
}

cleanup() {
    if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
}

trap cleanup EXIT

detect_platform() {
    local uname_out
    uname_out="$(uname -s 2>/dev/null || true)"
    case "${uname_out}" in
        Darwin)
            PLATFORM="macos"
            ;;
        Linux)
            PLATFORM="linux"
            ;;
        MINGW*|MSYS*|CYGWIN*)
            PLATFORM="windows"
            ;;
        *)
            die "Unsupported platform '${uname_out:-unknown}'. Use macOS, Linux, or Windows (Git Bash/WSL)."
            ;;
    esac
}

resolve_theme_dir() {
    if [[ -n "${THEME_DIR}" ]]; then
        RESOLVED_THEME_DIR="${THEME_DIR}"
        return
    fi

    if [[ "${PLATFORM}" == "macos" ]]; then
        local standalone sandboxed
        standalone="${HOME}/Library/Application Support/abnerworks.Typora/themes"
        sandboxed="${HOME}/Library/Containers/abnerworks.Typora/Data/Library/Application Support/abnerworks.Typora/themes"
        if [[ -d "${standalone}" ]]; then
            RESOLVED_THEME_DIR="${standalone}"
            return
        fi
        if [[ -d "${sandboxed}" ]]; then
            RESOLVED_THEME_DIR="${sandboxed}"
            return
        fi
        CREATED_THEME_DIR=1
        RESOLVED_THEME_DIR="${standalone}"
        return
    fi

    if [[ "${PLATFORM}" == "linux" ]]; then
        local xdg_config_home official flatpak
        xdg_config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
        official="${xdg_config_home}/Typora/themes"
        flatpak="${HOME}/.var/app/io.typora.Typora/config/Typora/themes"
        if [[ -d "${official}" ]]; then
            RESOLVED_THEME_DIR="${official}"
            return
        fi
        if [[ -d "${flatpak}" ]]; then
            RESOLVED_THEME_DIR="${flatpak}"
            return
        fi
        CREATED_THEME_DIR=1
        RESOLVED_THEME_DIR="${official}"
        return
    fi

    local appdata
    appdata="${APPDATA:-}"
    if [[ -z "${appdata}" ]]; then
        die "APPDATA is not set. On Windows, run this in Git Bash/WSL with APPDATA available or pass --theme-dir."
    fi
    if command -v cygpath >/dev/null 2>&1; then
        appdata="$(cygpath -u "${appdata}")"
    fi
    RESOLVED_THEME_DIR="${appdata}/Typora/themes"
    if [[ ! -d "${RESOLVED_THEME_DIR}" ]]; then
        CREATED_THEME_DIR=1
    fi
}

is_repo_checkout() {
    local candidate="$1"
    [[ -f "${candidate}/latex.css" ]] \
        && [[ -f "${candidate}/latex-dark.css" ]] \
        && [[ -d "${candidate}/latex_fonts" ]]
}

resolve_local_checkout_root() {
    local base_dir="$1"
    if is_repo_checkout "${base_dir}"; then
        printf '%s\n' "${base_dir}"
        return 0
    fi
    if is_repo_checkout "${base_dir}/.."; then
        printf '%s\n' "$(cd "${base_dir}/.." && pwd)"
        return 0
    fi
    return 1
}

download_source() {
    local archive_path extracted_dir archive_url
    require_command curl
    require_command tar
    require_command mktemp
    TEMP_DIR="$(mktemp -d)"
    archive_path="${TEMP_DIR}/theme.tar.gz"
    archive_url="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/${REF}"
    info "Downloading ${REPO_OWNER}/${REPO_NAME}@${REF}"
    curl -fsSL "${archive_url}" -o "${archive_path}"
    tar -xzf "${archive_path}" -C "${TEMP_DIR}"
    extracted_dir="$(find "${TEMP_DIR}" -mindepth 1 -maxdepth 1 -type d -print -quit)"
    if [[ -z "${extracted_dir}" ]] || ! is_repo_checkout "${extracted_dir}"; then
        die "Unable to find theme files in downloaded archive."
    fi
    SOURCE_DIR="${extracted_dir}"
    success "Downloaded source snapshot"
}

detect_source_dir() {
    local script_path script_dir checkout_root
    script_path="${BASH_SOURCE[0]:-$0}"
    if [[ -n "${script_path}" && -f "${script_path}" ]]; then
        script_dir="$(cd "$(dirname "${script_path}")" && pwd)"
        checkout_root="$(resolve_local_checkout_root "${script_dir}" || true)"
        if [[ -n "${checkout_root}" ]]; then
            SOURCE_DIR="${checkout_root}"
            success "Using local checkout at ${SOURCE_DIR}"
            return
        fi
    fi
    download_source
}

install_theme() {
    local source_dir="$1" theme_dir="$2"
    local css_files=()
    local font_files=()
    mkdir -p "${theme_dir}"
    mkdir -p "${theme_dir}/latex_fonts"
    shopt -s nullglob
    css_files=("${source_dir}"/latex*.css)
    font_files=("${source_dir}"/latex_fonts/*.otf "${source_dir}"/latex_fonts/*.ttf)
    shopt -u nullglob
    [[ ${#css_files[@]} -gt 0 ]] || die "No latex*.css theme files found in source."
    [[ ${#font_files[@]} -gt 0 ]] || die "No font files found in source."
    cp "${css_files[@]}" "${theme_dir}/"
    cp "${font_files[@]}" "${theme_dir}/latex_fonts/"
}

main() {
    print_banner
    step "Step 1/5: Checking requirements"
    require_command cp
    validate_ref
    success "Required commands are available"

    step "Step 2/5: Detecting your platform"
    detect_platform
    success "Detected platform: ${PLATFORM}"

    step "Step 3/5: Locating installation source"
    detect_source_dir

    step "Step 4/5: Resolving Typora theme directory"
    resolve_theme_dir
    info "Target directory: ${RESOLVED_THEME_DIR}"
    if [[ "${CREATED_THEME_DIR}" -eq 1 ]]; then
        warn "Theme directory does not exist yet; installer will create it."
    fi
    success "Theme directory resolved"

    step "Step 5/5: Installing files"
    install_theme "${SOURCE_DIR}" "${RESOLVED_THEME_DIR}"
    success "Installed latex.css"
    success "Installed latex-dark.css"
    success "Installed latex-dev-dark.css"
    success "Installed latex_fonts/*.{otf,ttf}"

    printf '\n%b\n' "${BOLD}${GREEN}Done!${RESET} Restart Typora or switch to latex / latex-dark / latex-dev-dark in the Themes menu."
}

main
