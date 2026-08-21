#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="shamsghi"
REPO_NAME="LatexTypora"
DEFAULT_REF="${LATEX_TYPORA_REF:-main}"
SCRIPT_USAGE_PATH="${LATEX_TYPORA_SCRIPT_USAGE_PATH:-./scripts/install.sh}"
REMOTE_INSTALL_SCRIPT_URL="${LATEX_TYPORA_INSTALL_SCRIPT_URL:-https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/scripts/install.sh}"

THEME_DIR="${TYPORA_THEME_DIR:-}"
REF="$DEFAULT_REF"
TEMP_DIR=""
SOURCE_DIR=""
RESOLVED_THEME_DIR=""
PLATFORM=""
CREATED_THEME_DIR=0

BOLD=""
DIM=""
RESET=""
BLUE=""
MAGENTA=""
GREEN=""
YELLOW=""
RED=""

MANIFEST_NAME=".latex-typora-manifest"
PRUNE=1

ENABLE_ANIMATIONS=0
ANIMATION_DELAY="${LATEX_TYPORA_ANIMATION_DELAY:-0.03}"
SPINNER_INTERVAL="${LATEX_TYPORA_SPINNER_INTERVAL:-0.08}"
TITLE_DELAY="${LATEX_TYPORA_TITLE_DELAY:-0.02}"
TERM_WIDTH=80
NO_ANIM_FLAG=0
PLAIN_OUTPUT=0

usage() {
    cat <<EOF
Usage:
  ${SCRIPT_USAGE_PATH} [--theme-dir PATH] [--ref REF]
  curl -fsSL ${REMOTE_INSTALL_SCRIPT_URL} | bash

Options:
  --theme-dir PATH  Install into a specific Typora theme directory.
  --ref REF         Install a specific branch, tag, or commit. Default: ${DEFAULT_REF}
  --no-prune        Keep theme files this version no longer ships.
  --no-anim         Disable animated banner and spinner output.
  --plain           Disable colors and animations.
  -h, --help        Show this help message.

Environment:
  TYPORA_THEME_DIR  Same as --theme-dir.
  LATEX_TYPORA_REF  Same as --ref.
  LATEX_TYPORA_NO_ANIM  Set to 1 to disable banner animations.
  LATEX_TYPORA_NO_COLOR  Set to 1 to disable ANSI colors.
  NO_COLOR  Standard variable to disable ANSI colors.
  LATEX_TYPORA_ANIMATION_DELAY  Seconds between banner lines. Default: 0.03
  LATEX_TYPORA_SPINNER_INTERVAL  Seconds between spinner frames. Default: 0.08
  LATEX_TYPORA_TITLE_DELAY  Seconds between title lines. Default: 0.02
EOF
}

configure_ui() {
    local color_enabled=0
    local cols=""

    if [[ "${PLAIN_OUTPUT}" -eq 0 ]] \
        && [[ -t 1 ]] \
        && [[ "${TERM:-}" != "dumb" ]] \
        && [[ -z "${NO_COLOR:-}" ]] \
        && [[ "${LATEX_TYPORA_NO_COLOR:-0}" != "1" ]]; then
        color_enabled=1
    fi

    if [[ "${color_enabled}" -eq 1 ]]; then
        BOLD="\033[1m"
        DIM="\033[2m"
        RESET="\033[0m"
        BLUE="\033[34m"
        MAGENTA="\033[90m"
        GREEN="\033[34m"
        YELLOW="\033[33m"
        RED="\033[31m"
    fi

    if [[ "${PLAIN_OUTPUT}" -eq 0 ]] \
        && [[ -t 1 ]] \
        && [[ "${TERM:-}" != "dumb" ]] \
        && [[ -z "${CI:-}" ]] \
        && [[ "${LATEX_TYPORA_NO_ANIM:-0}" != "1" ]] \
        && [[ "${NO_ANIM_FLAG}" -ne 1 ]]; then
        ENABLE_ANIMATIONS=1
    else
        ENABLE_ANIMATIONS=0
    fi

    cols="${LATEX_TYPORA_TERM_WIDTH:-}"
    if [[ -z "${cols}" ]] && command -v tput >/dev/null 2>&1 && [[ -t 1 ]]; then
        cols="$(tput cols 2>/dev/null || true)"
    fi
    if [[ "${cols}" =~ ^[0-9]+$ ]] && [[ "${cols}" -gt 0 ]]; then
        TERM_WIDTH="${cols}"
    fi
}

repeat_char() {
    local char="$1"
    local count="$2"
    local out=""

    [[ "${count}" -gt 0 ]] || return 0
    printf -v out '%*s' "${count}" ''
    printf '%s' "${out// /${char}}"
}

print_centered_line() {
    local color="$1"
    local line="$2"
    local line_len pad

    line_len="${#line}"
    if [[ "${TERM_WIDTH}" -gt "${line_len}" ]]; then
        pad=$(( (TERM_WIDTH - line_len) / 2 ))
    else
        pad=0
    fi
    printf '%*s%b\n' "${pad}" '' "${color}${line}${RESET}"
}

sleep_for() {
    [[ "${ENABLE_ANIMATIONS}" -eq 1 ]] || return 0
    sleep "$1" 2>/dev/null || sleep 0.03
}

print_banner() {
    local line
    local rule_width

    rule_width=72
    if [[ "${TERM_WIDTH}" -gt 6 ]]; then
        rule_width=$((TERM_WIDTH - 2))
    fi

    printf '\n'
    printf '%b%s%b\n' "${DIM}${BLUE}" "$(repeat_char '=' "${rule_width}")" "${RESET}"

    if [[ "${TERM_WIDTH}" -ge 74 ]]; then
        while IFS= read -r line; do
            print_centered_line "${BOLD}${BLUE}" "${line}"
            sleep_for "${TITLE_DELAY}"
        done <<'EOF'
ooooo                  ooooooooooooo           ooooooo  ooooo 
`888'                  8'   888   `8            `8888    d8'  
 888          .oooo.        888       .ooooo.     Y888..8P    
 888         `P  )88b       888      d88' `88b     `8888'     
 888          .oP"888       888      888ooo888    .8PY888.    
 888       o d8(  888       888      888    .o   d8'  `888b   
o888ooooood8 `Y888""8o     o888o     `Y8bod8P' o888o  o88888o 
EOF

        printf '\n'
        while IFS= read -r line; do
            print_centered_line "${BOLD}${MAGENTA}" "${line}"
            sleep_for "${TITLE_DELAY}"
        done <<'EOF'
""8""                                 
  8   e    e eeeee eeeee eeeee  eeeee 
  8e  8    8 8   8 8  88 8   8  8   8 
  88  8eeee8 8eee8 8   8 8eee8e 8eee8 
  88    88   88    8   8 88   8 88  8 
  88    88   88    8eee8 88   8 88  8 
EOF
    else
        while IFS= read -r line; do
            print_centered_line "${BOLD}${BLUE}" "${line}"
            sleep_for "${TITLE_DELAY}"
        done <<'EOF'
   _         ______  _      
\_|_)       (_) |   (_\  /  
  |     __,     | _    \/   
 _|    /  |   _ ||/    /\   
(/\___/\_/|_/(_/ |__/_/  \_/
EOF

        printf '\n'
        while IFS= read -r line; do
            print_centered_line "${BOLD}${MAGENTA}" "${line}"
            sleep_for "${TITLE_DELAY}"
        done <<'EOF'
 __  __          
|  \/  |___  ___ 
| |\/| / _ \/ _ \
|_|  |_\___/\___/
EOF
    fi

    printf '%b%s%b\n' "${DIM}${BLUE}" "$(repeat_char '=' "${rule_width}")" "${RESET}"
    printf '\n'
}

step() {
    printf '%b\n' "${BOLD}${BLUE}=>${RESET} ${BOLD}$1${RESET}"
}

info() {
    printf '%b\n' "${BLUE}  -${RESET} $1"
}

success() {
    printf '%b\n' "${GREEN}  [ok]${RESET} $1"
}

warn() {
    printf '%b\n' "${YELLOW}  [!]${RESET} $1"
}

print_completion_block() {
    local rule_width

    rule_width=72
    if [[ "${TERM_WIDTH}" -gt 6 ]]; then
        rule_width=$((TERM_WIDTH - 2))
    fi

    printf '\n%b%s%b\n' "${BOLD}${BLUE}" "$(repeat_char '=' "${rule_width}")" "${RESET}"
    print_centered_line "${BOLD}${BLUE}" "INSTALLATION COMPLETE"
    print_centered_line "${BOLD}" "LaTeX Typora theme assets are installed."
    printf '%b%s%b\n' "${DIM}${BLUE}" "$(repeat_char '-' "${rule_width}")" "${RESET}"
    info "In Typora, choose a theme: latex, latex-dark, or latex-dev-dark."
    info "If the themes are missing, restart Typora."
    printf '%b%s%b\n' "${BOLD}${BLUE}" "$(repeat_char '=' "${rule_width}")" "${RESET}"
}

die() {
    printf '%b\n' "${RED}  [x] $1${RESET}" >&2
    exit 1
}

run_with_spinner() {
    local label="$1"
    shift

    if [[ "${ENABLE_ANIMATIONS}" -ne 1 ]]; then
        "$@"
        return
    fi

    local spinner='-|\\/'
    local frame_index=0
    local command_pid
    local status

    "$@" &
    command_pid=$!

    while kill -0 "${command_pid}" 2>/dev/null; do
        printf '\r%b' "${BLUE}[${spinner:${frame_index}:1}]${RESET} ${label}"
        frame_index=$(((frame_index + 1) % 4))
        sleep "${SPINNER_INTERVAL}" 2>/dev/null || sleep 0.08
    done

    if wait "${command_pid}"; then
        status=0
    else
        status=$?
    fi

    if [[ "${status}" -eq 0 ]]; then
        printf '\r%b\n' "${GREEN}[ok]${RESET} ${label}"
    else
        printf '\r%b\n' "${RED}[x]${RESET} ${label}"
    fi

    return "${status}"
}

render_progress() {
    local current="$1"
    local total="$2"
    local label="$3"
    local width=28
    local percent filled empty
    local filled_bar empty_bar

    [[ "${ENABLE_ANIMATIONS}" -eq 1 ]] || return 0
    [[ "${total}" -gt 0 ]] || return 0

    percent=$(( current * 100 / total ))
    filled=$(( current * width / total ))
    empty=$(( width - filled ))

    printf -v filled_bar '%*s' "${filled}" ''
    filled_bar="${filled_bar// /=}"
    printf -v empty_bar '%*s' "${empty}" ''
    empty_bar="${empty_bar// /.}"

    printf '%b\n' "${MAGENTA}[${filled_bar}${empty_bar}]${RESET} ${percent}%% ${label}"
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
        --no-prune)
            PRUNE=0
            shift
            ;;
        --no-anim)
            NO_ANIM_FLAG=1
            shift
            ;;
        --plain)
            NO_ANIM_FLAG=1
            PLAIN_OUTPUT=1
            shift
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

configure_ui

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
    require_command find
    TEMP_DIR="$(mktemp -d)"
    archive_path="${TEMP_DIR}/theme.tar.gz"
    archive_url="https://codeload.github.com/${REPO_OWNER}/${REPO_NAME}/tar.gz/${REF}"
    run_with_spinner "Downloading ${REPO_OWNER}/${REPO_NAME}@${REF}" curl -fsSL "${archive_url}" -o "${archive_path}"
    run_with_spinner "Extracting source snapshot" tar -xzf "${archive_path}" -C "${TEMP_DIR}"
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

# Paths this run installed, relative to the theme directory. The manifest
# records them so the next run can tell a file the theme still ships from
# one it dropped -- a renamed font otherwise sits in the theme folder for
# good, since copying alone never removes anything.
INSTALLED_RELPATHS=()

is_owned_path() {
    # Only ever consider paths this installer writes, and never a user's
    # own <theme>.user.css overrides.
    local rel="$1"
    case "${rel}" in
        *..*|/*) return 1 ;;
        *.user.css) return 1 ;;
        latex_fonts/*.otf|latex_fonts/*.ttf|latex_fonts/*.css) return 0 ;;
        latex*.css) return 0 ;;
        *) return 1 ;;
    esac
}

prune_stale() {
    local theme_dir="$1"
    local manifest="${theme_dir}/${MANIFEST_NAME}"
    local -a candidates=()
    local rel installed removed=0

    # Anything the previous run installed, plus any font or generated font
    # stylesheet sitting in our own directory, so a folder predating the
    # manifest still gets cleaned.
    if [[ -f "${manifest}" ]]; then
        while IFS= read -r rel; do
            [[ -n "${rel}" ]] && candidates+=("${rel}")
        done < "${manifest}"
    fi
    shopt -s nullglob
    for rel in "${theme_dir}"/latex_fonts/*.otf "${theme_dir}"/latex_fonts/*.ttf \
        "${theme_dir}"/latex_fonts/*.css; do
        candidates+=("latex_fonts/$(basename "${rel}")")
    done
    shopt -u nullglob

    for rel in "${candidates[@]}"; do
        is_owned_path "${rel}" || continue
        [[ -f "${theme_dir}/${rel}" ]] || continue
        installed=0
        for keep in "${INSTALLED_RELPATHS[@]}"; do
            [[ "${keep}" == "${rel}" ]] && { installed=1; break; }
        done
        [[ "${installed}" -eq 1 ]] && continue
        if [[ "${PRUNE}" -eq 1 ]]; then
            rm -f "${theme_dir}/${rel}" && { info "Removed stale ${rel}"; removed=$((removed + 1)); }
        else
            warn "Stale ${rel} kept (--no-prune)"
        fi
    done

    if [[ "${removed}" -gt 0 ]]; then
        success "Removed ${removed} file(s) this version no longer ships"
    fi
}

write_manifest() {
    local theme_dir="$1" rel
    printf '%s\n' "${INSTALLED_RELPATHS[@]}" | LC_ALL=C sort > "${theme_dir}/${MANIFEST_NAME}"
}

install_theme() {
    local source_dir="$1" theme_dir="$2"
    local css_files=()
    local font_files=()
    local f
    mkdir -p "${theme_dir}"
    mkdir -p "${theme_dir}/latex_fonts"
    shopt -s nullglob
    css_files=("${source_dir}"/latex*.css)
    # The generated embedded-fonts*.css live beside the fonts they carry and
    # are copied with them: latex.css imports them, and a top-level .css would
    # show up in Typora's theme menu as a theme of its own.
    font_files=("${source_dir}"/latex_fonts/*.otf "${source_dir}"/latex_fonts/*.ttf \
        "${source_dir}"/latex_fonts/*.css)
    shopt -u nullglob
    [[ ${#css_files[@]} -gt 0 ]] || die "No latex*.css theme files found in source."
    [[ ${#font_files[@]} -gt 0 ]] || die "No font files found in source."
    run_with_spinner "Copying latex*.css files" cp "${css_files[@]}" "${theme_dir}/"
    run_with_spinner "Copying latex_fonts files" cp "${font_files[@]}" "${theme_dir}/latex_fonts/"

    INSTALLED_RELPATHS=()
    for f in "${css_files[@]}"; do
        INSTALLED_RELPATHS+=("$(basename "${f}")")
    done
    for f in "${font_files[@]}"; do
        INSTALLED_RELPATHS+=("latex_fonts/$(basename "${f}")")
    done

    prune_stale "${theme_dir}"
    write_manifest "${theme_dir}"
}

main() {
    local total_steps=5
    local current_step=0

    print_banner
    step "Step 1/5: Checking requirements"
    require_command cp
    validate_ref
    success "Required commands are available"
    current_step=$((current_step + 1))
    render_progress "${current_step}" "${total_steps}" "Requirements checked"

    step "Step 2/5: Detecting your platform"
    detect_platform
    success "Detected platform: ${PLATFORM}"
    current_step=$((current_step + 1))
    render_progress "${current_step}" "${total_steps}" "Platform detected"

    step "Step 3/5: Locating installation source"
    detect_source_dir
    current_step=$((current_step + 1))
    render_progress "${current_step}" "${total_steps}" "Source ready"

    step "Step 4/5: Resolving Typora theme directory"
    resolve_theme_dir
    info "Target directory: ${RESOLVED_THEME_DIR}"
    if [[ "${CREATED_THEME_DIR}" -eq 1 ]]; then
        warn "Theme directory does not exist yet; installer will create it."
    fi
    success "Theme directory resolved"
    current_step=$((current_step + 1))
    render_progress "${current_step}" "${total_steps}" "Destination ready"

    step "Step 5/5: Installing files"
    install_theme "${SOURCE_DIR}" "${RESOLVED_THEME_DIR}"
    success "Installed latex.css"
    success "Installed latex-dark.css"
    success "Installed latex-dev-dark.css"
    success "Installed latex_fonts/*.{otf,ttf,css}"
    current_step=$((current_step + 1))
    render_progress "${current_step}" "${total_steps}" "Installation complete"

    print_completion_block
}

main
