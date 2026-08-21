#!/usr/bin/env bash
#
# Installs the LaTeX Typora theme, either from the checkout this script sits
# in or from a tarball of the requested ref.
#
# What it writes, and nothing outside it:
#
#   <theme dir>/latex*.css               the theme stylesheets
#   <theme dir>/latex_fonts/*.otf|*.ttf  the bundled faces
#   <theme dir>/latex_fonts/*.css        the generated @font-face sheets
#   <theme dir>/.latex-typora-manifest   the paths this run installed
#
# The only files it ever deletes are ones listed in the previous run's
# manifest, or fonts sitting in its own latex_fonts folder, that this
# version no longer ships -- see is_owned_path() for the whitelist and
# prune_stale() for the rule. Your own <theme>.user.css overrides are
# excluded by name; --no-prune skips the removal entirely.
#
# Downloaded sources are unpacked into a mktemp directory that cleanup()
# removes on every exit path, including Ctrl-C.
#
# Reading order: settings, then terminal state, then the output primitives,
# then argument parsing, then one function per stage of the install, with
# main() at the bottom as the running order.

set -euo pipefail

# --------------------------------------------------------------------------
# Repository and run settings
# --------------------------------------------------------------------------

REPO_OWNER="shamsghi"
REPO_NAME="LatexTypora"
DEFAULT_REF="${LATEX_TYPORA_REF:-main}"
SCRIPT_USAGE_PATH="${LATEX_TYPORA_SCRIPT_USAGE_PATH:-./scripts/install.sh}"
REMOTE_INSTALL_SCRIPT_URL="${LATEX_TYPORA_INSTALL_SCRIPT_URL:-https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/scripts/install.sh}"

# Overridable by flag or environment; resolved into the variables below.
THEME_DIR="${TYPORA_THEME_DIR:-}"
REF="$DEFAULT_REF"
TEMP_DIR=""
SOURCE_DIR=""
RESOLVED_THEME_DIR=""
PLATFORM=""
CREATED_THEME_DIR=0

# --------------------------------------------------------------------------
# Terminal state: palette, glyphs, and page geometry
# --------------------------------------------------------------------------

# Colors are named for the role they play, not the ink they happen to use:
# the palette deliberately answers "ok" in the theme's blue rather than the
# usual green, and secondary rules in grey. Empty until configure_ui decides
# the terminal should see ANSI at all.
BOLD=""
DIM=""
RESET=""
C_ACCENT=""
C_MUTED=""
C_OK=""
C_WARN=""
C_ERR=""

# Progress is reported in one voice per channel: the step header carries
# the words, the bar carries the proportion. TOTAL_STEPS must match the
# number of step() calls in main(); CURRENT_STEP is advanced by step()
# itself so the numbering cannot drift out of sync with the headers.
TOTAL_STEPS=5
CURRENT_STEP=0

# Left margin shared by every status line, and the width of the tag column
# ([ok], [!], the spinner frame) that follows it.
GUTTER="  "
TAG_WIDTH=4

MANIFEST_NAME=".latex-typora-manifest"
PRUNE=1

ENABLE_ANIMATIONS=0
# Frame interval for the drawing animations: the rule sweep, the ink pass
# under each banner line, and the progress fill.
ANIMATION_DELAY="${LATEX_TYPORA_ANIMATION_DELAY:-0.012}"
SPINNER_INTERVAL="${LATEX_TYPORA_SPINNER_INTERVAL:-0.08}"
TITLE_DELAY="${LATEX_TYPORA_TITLE_DELAY:-0.02}"

# Glyph sets, chosen in configure_ui. The Unicode set is only reached for
# when the locale says the terminal can render it; Git Bash and a bare C
# locale get the ASCII set.
UNICODE_OK=0
SPINNER_FRAMES=()
BAR_FILL="="
BAR_HEAD=">"
BAR_TRACK="."
RULE_HEAVY="="
RULE_LIGHT="-"
# Percentage already drawn, so the next tick can grow into place instead of
# appearing at its final length.
PROGRESS_LAST=0
TERM_WIDTH=80
# The output is laid out on a fixed measure, centered in the terminal,
# rather than stretched edge to edge: a rule drawn across a 200-column
# window dwarfs the 55 columns of art it is meant to frame. FRAME_WIDTH is
# that measure, FRAME_INDENT the left offset that centers it, and FRAME_PAD
# the same offset as literal spaces. All three are derived in configure_ui.
MAX_MEASURE="${LATEX_TYPORA_MAX_WIDTH:-76}"
FRAME_WIDTH=76
FRAME_INDENT=0
FRAME_PAD=""
NO_ANIM_FLAG=0
PLAIN_OUTPUT=0

# PID of the command a spinner is currently supervising, so an interrupt can
# stop it instead of leaving a detached curl running. Empty when idle.
BACKGROUND_PID=""
# Whether we have hidden the terminal cursor and still owe the user a
# restore, even on an abnormal exit.
CURSOR_HIDDEN=0

# --------------------------------------------------------------------------
# Output primitives
# --------------------------------------------------------------------------

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
  LATEX_TYPORA_ANIMATION_DELAY  Seconds between drawing frames. Default: 0.012
  LATEX_TYPORA_SPINNER_INTERVAL  Seconds between spinner frames. Default: 0.08
  LATEX_TYPORA_TITLE_DELAY  Seconds between title lines. Default: 0.02
  LATEX_TYPORA_MAX_WIDTH  Widest the framed output may be drawn. Default: 76
EOF
}

# Decides once what this terminal can be shown -- color, animation, Unicode
# glyphs -- and derives the page geometry from its width. Everything below
# reads those decisions rather than re-testing the terminal, so a single set
# of rules governs the whole run.
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
        C_ACCENT="\033[34m"   # blue: rules, step markers, the spinner
        C_MUTED="\033[90m"   # grey: secondary rules and the progress bar
        C_OK="\033[34m"      # blue, matching the accent, not a green
        C_WARN="\033[33m"    # yellow
        C_ERR="\033[31m"     # red
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

    # Braille spins far more smoothly than four ASCII frames, and a solid
    # block bar reads better than equals signs -- but only where the
    # terminal can actually draw them.
    if [[ "${PLAIN_OUTPUT}" -eq 0 ]] \
        && [[ "${LC_ALL:-${LC_CTYPE:-${LANG:-}}}" == *[Uu][Tt][Ff]* ]]; then
        UNICODE_OK=1
    fi

    if [[ "${UNICODE_OK}" -eq 1 ]]; then
        SPINNER_FRAMES=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
        BAR_FILL="━"
        BAR_HEAD="╸"
        BAR_TRACK="─"
        RULE_HEAVY="═"
        RULE_LIGHT="─"
    else
        SPINNER_FRAMES=("-" "\\" "|" "/")
        BAR_FILL="="
        BAR_HEAD=">"
        BAR_TRACK="."
        RULE_HEAVY="="
        RULE_LIGHT="-"
    fi

    if [[ ! "${MAX_MEASURE}" =~ ^[0-9]+$ ]] || [[ "${MAX_MEASURE}" -lt 20 ]]; then
        MAX_MEASURE=76
    fi

    # Two columns of breathing room inside the terminal, capped at the
    # measure, then centered. Narrow terminals simply get everything.
    FRAME_WIDTH=$((TERM_WIDTH - 2))
    if [[ "${FRAME_WIDTH}" -gt "${MAX_MEASURE}" ]]; then
        FRAME_WIDTH="${MAX_MEASURE}"
    fi
    if [[ "${FRAME_WIDTH}" -lt 20 ]]; then
        FRAME_WIDTH=20
    fi

    FRAME_INDENT=$(( (TERM_WIDTH - FRAME_WIDTH) / 2 ))
    if [[ "${FRAME_INDENT}" -lt 0 ]]; then
        FRAME_INDENT=0
    fi
    printf -v FRAME_PAD '%*s' "${FRAME_INDENT}" ''
    # Status lines hang two columns inside the frame's left edge, so body
    # text and rules belong to the same column of type.
    printf -v GUTTER '%*s' "$((FRAME_INDENT + 2))" ''
}

# A run of one character. Built by padding with spaces and substituting, so
# no subshell or seq is needed for what is a very hot path during the rule
# and bar animations.
repeat_char() {
    local char="$1"
    local count="$2"
    local out=""

    [[ "${count}" -gt 0 ]] || return 0
    printf -v out '%*s' "${count}" ''
    printf '%s' "${out// /${char}}"
}

# A horizontal rule the full width of the measure.
print_rule() {
    local color="$1" char="$2"
    local frames=12 i drawn

    # Animated, the rule is set left to right the way a \hrule lands on a
    # page; otherwise it is simply printed.
    if [[ "${ENABLE_ANIMATIONS}" -eq 1 ]]; then
        hide_cursor
        for ((i = 1; i < frames; i++)); do
            drawn=$(( FRAME_WIDTH * i / frames ))
            reset_line
            printf '%b%s%b' "${FRAME_PAD}${color}" "$(repeat_char "${char}" "${drawn}")" "${RESET}"
            sleep_for "${ANIMATION_DELAY}"
        done
        reset_line
        show_cursor
    fi
    printf '%b%s%b\n' "${FRAME_PAD}${color}" "$(repeat_char "${char}" "${FRAME_WIDTH}")" "${RESET}"
}

# One line centered inside the measure, not inside the terminal.
print_centered_line() {
    local color="$1"
    local line="$2"
    local pad=0

    if [[ "${FRAME_WIDTH}" -gt "${#line}" ]]; then
        pad=$(( (FRAME_WIDTH - ${#line}) / 2 ))
    fi
    # The line itself is printed with %s. Under %b a backslash in the ASCII
    # art would be read as an escape sequence.
    printf '%*s%b%s%b\n' "$((FRAME_INDENT + pad))" '' "${color}" "${line}" "${RESET}"
}

# Centers a block of ASCII art as one rigid unit: every line shifts by the
# same amount, measured from the widest line once trailing whitespace is
# stripped. Centering each line on its own length instead would rely on the
# art being hand-padded to equal width, which any editor or hook that trims
# trailing whitespace would silently undo, skewing the logo with no error.
print_art_block() {
    local color="$1"
    local -a lines=()
    local line trailing trimmed width=0 pad

    while IFS= read -r line; do
        trailing="${line##*[![:space:]]}"
        trimmed="${line%${trailing}}"
        lines+=("${trimmed}")
        if [[ "${#trimmed}" -gt "${width}" ]]; then
            width="${#trimmed}"
        fi
    done

    pad=0
    if [[ "${FRAME_WIDTH}" -gt "${width}" ]]; then
        pad=$(( (FRAME_WIDTH - width) / 2 ))
    fi
    pad=$((FRAME_INDENT + pad))

    hide_cursor
    for line in "${lines[@]}"; do
        # Each line is set in light ink first and then darkens into place,
        # so the wordmark reads as being typeset rather than pasted in.
        if [[ "${ENABLE_ANIMATIONS}" -eq 1 && -n "${line}" ]]; then
            printf '%*s%b%s%b' "${pad}" '' "${DIM}" "${line}" "${RESET}"
            sleep_for "${ANIMATION_DELAY}"
            reset_line
        fi
        printf '%*s%b%s%b\n' "${pad}" '' "${color}" "${line}" "${RESET}"
        sleep_for "${TITLE_DELAY}"
    done
    show_cursor
}

# Shows $HOME as ~, so a long install path stays inside the measure and a
# screenshot does not carry the account name.
display_path() {
    local path="$1"
    if [[ -n "${HOME:-}" && "${path}" == "${HOME}/"* ]]; then
        printf '~/%s' "${path#"${HOME}/"}"
    else
        printf '%s' "${path}"
    fi
}

sleep_for() {
    [[ "${ENABLE_ANIMATIONS}" -eq 1 ]] || return 0
    sleep "$1" 2>/dev/null || sleep 0.03
}

# The cursor blinks on top of an in-place spinner, so park it while one is
# running. Only ever hidden when we are already emitting ANSI, and always
# restored through cleanup().
hide_cursor() {
    [[ "${ENABLE_ANIMATIONS}" -eq 1 ]] || return 0
    CURSOR_HIDDEN=1
    printf '\033[?25l'
}

show_cursor() {
    [[ "${CURSOR_HIDDEN}" -eq 1 ]] || return 0
    CURSOR_HIDDEN=0
    printf '\033[?25h'
}

# Return to column 0 and erase the row. Rewriting with \r alone leaves the
# tail of a longer previous frame on screen.
reset_line() {
    printf '\r\033[2K'
}

# The LATEX / Typora lockup. Both wordmarks are heredocs so they can be
# read and edited as the pictures they are.
print_banner() {
    printf '\n'
    print_rule "${DIM}${C_ACCENT}" "${RULE_HEAVY}"

    # Two sets of wordmarks. The wide pair needs 59 columns of measure; the
    # narrow pair is drawn whenever the frame is tighter than that.
    if [[ "${FRAME_WIDTH}" -ge 60 ]]; then
        print_art_block "${BOLD}${C_ACCENT}" <<'EOF'
      ooooo      o   ooooooooooooo       ooooooo  ooooo
     `888'     888  8'   888   `8        `8888    d8'  
     888     8  88      888  oooooooooooo Y888..8P     
     888    8oooo88     888  `888'     `8  `8888'      
    888  o88o  o888o   888   888         .8PY888.      
   888       o        888   888oooo8   d8'  `888b      
 o888ooooood8       o888o  888    " o888o  o88888o     
                           888       o                 
                         o888ooooood8                  
EOF

        printf '\n'
        print_art_block "${BOLD}${C_MUTED}" <<'EOF'
"""88"""                                                   
"""88"""                                                   
   88   ee      ee  eeeeeeee  eeeeeeee  eeeeeeee   eeeeeeee
   88e  88      88  88    88  88    88  88    88   88    88
   88e  88      88  88    88  88    88  88    88   88    88
   888  88eeeeee88  88eeee88  88    88  88eeee88e  88eeee88
   888     888      888       88    88  888     8  888   88
   888     888      888       88    88  888     8  888   88
   888     888      888       88eeee88  888     8  888   88
EOF
    else
        print_art_block "${BOLD}${C_ACCENT}" <<'EOF'
8      88888     Yb  dP
8   db   8  8888  YbdP 
8  dPYb  8  8www  dPYb 
8888     8  8    dP  Yb
            8888       
EOF

        printf '\n'
        print_art_block "${BOLD}${C_MUTED}" <<'EOF'
88888                            
  8   Yb  dP 88b. .d8b. 8d8b .d88
  8    YbdP  8  8 8' .8 8P   8  8
  8     dP   88P' `Y8P' 8    `Y88
       dP    8                   
EOF
    fi

    print_rule "${DIM}${C_ACCENT}" "${RULE_HEAVY}"
    printf '\n'
}

# Every status line is built from one primitive so the markers line up:
# a shared left margin, a fixed-width tag column, then the message. An
# [ok] printed by a spinner therefore lands in the same columns as one
# printed directly, instead of hugging column zero.
status_line() {
    local color="$1" tag="$2" text="$3"
    printf '%b\n' "$(status_prefix "${color}" "${tag}")${text}"
}

status_prefix() {
    local color="$1" tag="$2" pad
    # Padded by character count rather than with %-*s, which measures bytes:
    # a multibyte spinner frame would otherwise lose a column and make the
    # message text shuffle sideways as it spins.
    pad=$((TAG_WIDTH - ${#tag}))
    if [[ "${pad}" -lt 0 ]]; then
        pad=0
    fi
    printf '%s' "${GUTTER}${color}${tag}$(repeat_char ' ' "${pad}")${RESET} "
}

# A stage heading. Numbering is derived, never written by the caller.
step() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    printf '%b\n' "${FRAME_PAD}${BOLD}${C_ACCENT}=>${RESET} ${BOLD}Step ${CURRENT_STEP}/${TOTAL_STEPS}: $1${RESET}"
}

info() {
    status_line "${C_ACCENT}" " - " "$1"
}

success() {
    status_line "${C_OK}" "[ok]" "$1"
}

warn() {
    status_line "${C_WARN}" "[!]" "$1"
}

# The closing panel. Reads the globals that install_theme filled in, so it
# describes the run that actually happened.
print_completion_block() {
    printf '\n'
    print_rule "${BOLD}${C_ACCENT}" "${RULE_HEAVY}"
    print_centered_line "${BOLD}${C_ACCENT}" "INSTALLATION COMPLETE"
    print_centered_line "${BOLD}" "LaTeX Typora theme assets are installed."
    print_rule "${DIM}${C_ACCENT}" "${RULE_LIGHT}"
    # The install path is named again here: it was last mentioned four steps
    # ago, and this block is the one people scroll back to.
    info "Installed to: $(display_path "${RESOLVED_THEME_DIR}")"
    sleep_for "${TITLE_DELAY}"
    info "In Typora, choose a theme: $(join_list "${INSTALLED_THEMES[@]}")."
    sleep_for "${TITLE_DELAY}"
    info "If the themes are missing, restart Typora."
    sleep_for "${TITLE_DELAY}"
    print_rule "${BOLD}${C_ACCENT}" "${RULE_HEAVY}"
}

# "1 stylesheet" / "3 stylesheets". Only ever used on words that take a
# plain -s plural.
plural() {
    local count="$1" word="$2"
    if [[ "${count}" -eq 1 ]]; then
        printf '%s %s' "${count}" "${word}"
    else
        printf '%s %ss' "${count}" "${word}"
    fi
}

# "a, b, c" -- for naming installed themes in prose.
join_list() {
    local out="" item
    for item in "$@"; do
        [[ -n "${out}" ]] && out+=", "
        out+="${item}"
    done
    printf '%s' "${out}"
}

# Every failure leaves through here: one marker, one line, stderr, nonzero.
die() {
    status_line "${C_ERR}" "[x]" "$1" >&2
    exit 1
}

# Runs a command, reporting it as one status line. Animated runs spin a
# frame in place while it works; everything else still prints the same
# resolved line, so a piped log or a --plain run keeps a record of each
# download, extraction, and copy instead of a silent gap between steps.
run_with_spinner() {
    local label="$1"
    shift

    local status

    if [[ "${ENABLE_ANIMATIONS}" -ne 1 ]]; then
        # set -e would abort before the failure could be reported, so take
        # the status by hand here and let the caller act on the return.
        if "$@"; then
            status=0
        else
            status=$?
        fi
        report_status "${status}" "${label}"
        return "${status}"
    fi

    local frames="${#SPINNER_FRAMES[@]}"
    local frame_index=0

    "$@" &
    BACKGROUND_PID=$!
    hide_cursor

    while kill -0 "${BACKGROUND_PID}" 2>/dev/null; do
        reset_line
        printf '%b' "$(status_prefix "${C_ACCENT}" "[${SPINNER_FRAMES[frame_index]}]")${label}"
        frame_index=$(((frame_index + 1) % frames))
        sleep "${SPINNER_INTERVAL}" 2>/dev/null || sleep 0.08
    done

    # The loop exits once the child is gone; wait then only harvests its
    # status.
    if wait "${BACKGROUND_PID}"; then
        status=0
    else
        status=$?
    fi
    BACKGROUND_PID=""
    show_cursor

    reset_line
    report_status "${status}" "${label}"

    return "${status}"
}

# The resolved line a run_with_spinner call leaves behind, whichever path
# produced it.
report_status() {
    local status="$1" label="$2"
    if [[ "${status}" -eq 0 ]]; then
        success "${label}"
    else
        status_line "${C_ERR}" "[x]" "${label}"
    fi
}

# Draws the bar for the step that just finished. Takes no label: the
# header above it already named the step.
progress_tick() {
    render_progress "${CURRENT_STEP}" "${TOTAL_STEPS}"
}

render_progress() {
    local current="$1"
    local total="$2"
    local width=28
    local percent frame

    # Suppressed only by --plain. The finished bar is one whole line per
    # step, never an in-place redraw, so it stays readable in a log file.
    [[ "${PLAIN_OUTPUT}" -eq 0 ]] || return 0
    [[ "${total}" -gt 0 ]] || return 0

    percent=$(( current * 100 / total ))

    # Animated, the bar grows from where the last step left it to where this
    # one ends, which is the only part of the run that shows movement
    # between steps.
    if [[ "${ENABLE_ANIMATIONS}" -eq 1 ]]; then
        hide_cursor
        for ((frame = PROGRESS_LAST + 4; frame < percent; frame += 4)); do
            reset_line
            draw_bar "${frame}" "${width}"
            sleep_for "${ANIMATION_DELAY}"
        done
        reset_line
        show_cursor
    fi

    draw_bar "${percent}" "${width}"
    printf '\n'
    PROGRESS_LAST="${percent}"
}

# One frame of the progress bar, without a trailing newline so the animated
# path can redraw it in place.
draw_bar() {
    local percent="$1" width="$2"
    local filled empty body="" track=""

    filled=$(( percent * width / 100 ))
    if [[ "${filled}" -gt "${width}" ]]; then
        filled="${width}"
    fi
    empty=$(( width - filled ))

    if [[ "${filled}" -gt 0 ]] && [[ "${empty}" -gt 0 ]]; then
        # A distinct head on the leading edge gives a growing bar a
        # direction; a full bar has nowhere left to point.
        body="$(repeat_char "${BAR_FILL}" $((filled - 1)))${BAR_HEAD}"
    elif [[ "${filled}" -gt 0 ]]; then
        body="$(repeat_char "${BAR_FILL}" "${filled}")"
    fi
    track="$(repeat_char "${BAR_TRACK}" "${empty}")"

    # The percent literal belongs to this format string. Passed inside a %b
    # argument it printed a bare "%%" on screen.
    printf '%b%3d%%' "${GUTTER}${C_MUTED}[${body}${track}]${RESET} " "${percent}"
}

# --------------------------------------------------------------------------
# Command line
# --------------------------------------------------------------------------

# Parsed before configure_ui runs, since --plain and --no-anim decide what
# configure_ui is allowed to turn on. die() is safe to call here: with the
# palette still empty it simply prints without color.
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

# --------------------------------------------------------------------------
# Preconditions and cleanup
# --------------------------------------------------------------------------

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        die "Missing required command: $1"
    fi
}

# --ref is interpolated into a codeload URL, so it is restricted to the
# characters a branch, tag, or SHA can contain, with .. excluded outright.
validate_ref() {
    if [[ -z "${REF}" ]]; then
        die "Ref cannot be empty."
    fi
    if [[ "${REF}" =~ [^A-Za-z0-9._/\-] ]] || [[ "${REF}" == *".."* ]]; then
        die "Invalid --ref value '${REF}'. Use a branch, tag, or commit SHA."
    fi
}

# Runs on every exit path, including Ctrl-C. Ordered so the terminal is
# usable again before we spend time deleting anything, and written to be
# safe to run twice (an interrupt runs it, then the exit trap runs it again).
cleanup() {
    show_cursor
    if [[ -n "${BACKGROUND_PID}" ]] && kill -0 "${BACKGROUND_PID}" 2>/dev/null; then
        kill "${BACKGROUND_PID}" 2>/dev/null || true
        wait "${BACKGROUND_PID}" 2>/dev/null || true
    fi
    BACKGROUND_PID=""
    if [[ -n "${TEMP_DIR}" && -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
}

trap cleanup EXIT
# 128 + signal number, the conventional shell exit status for a signal.
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

# --------------------------------------------------------------------------
# Where we are, and where the theme goes
# --------------------------------------------------------------------------

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

# Typora keeps its themes in a different place per platform, and per
# install method within a platform: a Mac App Store copy is sandboxed under
# ~/Library/Containers, a Linux Flatpak under ~/.var/app. Prefer a directory
# that already exists -- its existence is the strongest signal of which
# install is real -- and fall back to the standard location, noting that we
# will have to create it.
resolve_theme_dir() {
    if [[ -n "${THEME_DIR}" ]]; then
        RESOLVED_THEME_DIR="${THEME_DIR}"
        if [[ ! -d "${RESOLVED_THEME_DIR}" ]]; then
            CREATED_THEME_DIR=1
        fi
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

# The marker files that tell a repository checkout from any other folder.
is_repo_checkout() {
    local candidate="$1"
    [[ -f "${candidate}/latex.css" ]] \
        && [[ -f "${candidate}/latex-dark.css" ]] \
        && [[ -d "${candidate}/latex_fonts" ]]
}

# Accepts the checkout root itself or scripts/ inside it, which is where
# this file normally lives.
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

# Fetches the ref as a tarball rather than requiring git, and verifies the
# unpacked tree really is a checkout before anything is copied out of it.
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
}

# Prefer the checkout this script was run from, so a local edit installs
# without a round trip through GitHub. Piped through curl there is no such
# checkout, and BASH_SOURCE is empty, so the download path takes over.
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

# Theme names as Typora lists them in its menu: the installed stylesheet
# file names without the .css extension. Reported at the end so the closing
# advice names the themes this run actually wrote.
INSTALLED_THEMES=()

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

# --------------------------------------------------------------------------
# Installing, pruning, and the manifest
# --------------------------------------------------------------------------

# The manifest is plain text, one relative path per line, sorted so a diff
# between runs is readable.
write_manifest() {
    local theme_dir="$1" rel
    printf '%s\n' "${INSTALLED_RELPATHS[@]}" | LC_ALL=C sort > "${theme_dir}/${MANIFEST_NAME}"
}

# Copies the theme into place, removes what this version dropped, then
# records what is now installed.
install_theme() {
    local source_dir="$1" theme_dir="$2"
    local css_files=()
    local font_files=()
    local f base name pass
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

    # Theme menu names, base themes ahead of their variants: two passes,
    # because glob order alone lists latex-dark.css before latex.css ('-'
    # sorts before '.').
    INSTALLED_THEMES=()
    for pass in base variant; do
        for f in "${css_files[@]}"; do
            base="$(basename "${f}")"
            # A <theme>.user.css is a user override, not a theme of its own.
            [[ "${base}" == *.user.css ]] && continue
            name="${base%.css}"
            [[ "${pass}" == "base" && "${name}" == *-* ]] && continue
            [[ "${pass}" == "variant" && "${name}" != *-* ]] && continue
            INSTALLED_THEMES+=("${name}")
        done
    done

    prune_stale "${theme_dir}"
    write_manifest "${theme_dir}"

    # Report what was copied, not what this version happens to ship: the
    # lists above come from the globs, so a renamed or dropped file shows up
    # here instead of being announced anyway.
    success "Installed $(plural "${#INSTALLED_THEMES[@]}" "theme"): $(join_list "${INSTALLED_THEMES[@]}")"
    success "Installed $(plural "${#font_files[@]}" "file") into latex_fonts/"
}

# --------------------------------------------------------------------------
# Running order
# --------------------------------------------------------------------------

main() {
    print_banner

    step "Checking requirements"
    require_command cp
    validate_ref
    success "Required commands are available"
    progress_tick

    step "Detecting your platform"
    detect_platform
    success "Detected platform: ${PLATFORM}"
    progress_tick

    step "Locating installation source"
    detect_source_dir
    progress_tick

    step "Resolving Typora theme directory"
    resolve_theme_dir
    info "Target directory: $(display_path "${RESOLVED_THEME_DIR}")"
    if [[ "${CREATED_THEME_DIR}" -eq 1 ]]; then
        warn "Theme directory does not exist yet; installer will create it."
    fi
    success "Theme directory resolved"
    progress_tick

    step "Installing files"
    install_theme "${SOURCE_DIR}" "${RESOLVED_THEME_DIR}"
    progress_tick

    print_completion_block
}

main
