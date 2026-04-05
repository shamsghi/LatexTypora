#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="shamsghi"
REPO_NAME="LatexTypora"
DEFAULT_REF="${LATEX_TYPORA_REF:-main}"

THEME_DIR="${TYPORA_THEME_DIR:-}"
REF="$DEFAULT_REF"
TEMP_DIR=""
CREATED_THEME_DIR=0
SOURCE_DIR=""
RESOLVED_THEME_DIR=""

usage() {
    cat <<EOF
Usage:
  ./scripts/install-linux.sh [--theme-dir PATH] [--ref REF]
  curl -fsSL https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/scripts/install-linux.sh | bash

Options:
  --theme-dir PATH  Install into a specific Typora theme directory.
  --ref REF         Install a specific branch, tag, or commit. Default: ${DEFAULT_REF}
  -h, --help        Show this help message.

Environment:
  TYPORA_THEME_DIR  Same as --theme-dir.
  LATEX_TYPORA_REF  Same as --ref.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --theme-dir)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
            THEME_DIR="$2"
            shift 2
            ;;
        --ref)
            [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
            REF="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Missing required command: $1" >&2
        exit 1
    fi
}

cleanup() {
    if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
}

trap cleanup EXIT

resolve_theme_dir() {
    local xdg_config_home
    local official
    local flatpak

    if [[ -n "${THEME_DIR}" ]]; then
        RESOLVED_THEME_DIR="${THEME_DIR}"
        return
    fi

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
    local archive_path
    local extracted_dir
    local archive_url

    require_command curl
    require_command tar
    require_command mktemp

    TEMP_DIR="$(mktemp -d)"
    archive_path="${TEMP_DIR}/theme.tar.gz"
    archive_url="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/${REF}"

    echo "Downloading ${REPO_OWNER}/${REPO_NAME}@${REF}..."
    curl -fsSL "${archive_url}" -o "${archive_path}"
    tar -xzf "${archive_path}" -C "${TEMP_DIR}"

    extracted_dir="$(find "${TEMP_DIR}" -mindepth 1 -maxdepth 1 -type d -print -quit)"
    if [[ -z "${extracted_dir}" ]] || ! is_repo_checkout "${extracted_dir}"; then
        echo "Unable to find theme files in the downloaded archive." >&2
        exit 1
    fi

    SOURCE_DIR="${extracted_dir}"
}

detect_source_dir() {
    local script_path
    local script_dir
    local checkout_root

    script_path="${BASH_SOURCE[0]:-$0}"
    script_dir=""

    if [[ -n "${script_path}" && -f "${script_path}" ]]; then
        script_dir="$(cd "$(dirname "${script_path}")" && pwd)"
    fi

    if [[ -n "${script_dir}" ]]; then
        checkout_root="$(resolve_local_checkout_root "${script_dir}" || true)"
        if [[ -n "${checkout_root}" ]]; then
            SOURCE_DIR="${checkout_root}"
            return
        fi
    fi

    download_source
}

install_theme() {
    local source_dir="$1"
    local theme_dir="$2"

    mkdir -p "${theme_dir}"
    mkdir -p "${theme_dir}/latex_fonts"

    cp "${source_dir}"/latex*.css "${theme_dir}/"
    cp "${source_dir}"/latex_fonts/*.otf "${theme_dir}/latex_fonts/"
}

main() {
    require_command cp

    detect_source_dir
    resolve_theme_dir

    echo "Installing LatexTypora into:"
    echo "  ${RESOLVED_THEME_DIR}"

    install_theme "${SOURCE_DIR}" "${RESOLVED_THEME_DIR}"

    echo
    echo "Installed files:"
    echo "  ${RESOLVED_THEME_DIR}/latex.css"
    echo "  ${RESOLVED_THEME_DIR}/latex-dark.css"
    echo "  ${RESOLVED_THEME_DIR}/latex-dev-dark.css"
    echo "  ${RESOLVED_THEME_DIR}/latex_fonts/*.otf"

    if [[ "${CREATED_THEME_DIR}" -eq 1 ]]; then
        echo
        echo "Created the default Typora theme directory because it did not already exist."
        echo "If your Typora install uses a different theme folder, rerun with:"
        echo "  ./scripts/install-linux.sh --theme-dir \"/path/to/Typora/themes\""
    fi

    echo
    echo "Restart Typora or switch to the Latex / Latex Dark / Latex Dev Dark theme from Themes."
}

main
