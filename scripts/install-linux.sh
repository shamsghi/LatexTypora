#!/usr/bin/env bash
set -euo pipefail

REPO_OWNER="shamsghi"
REPO_NAME="LatexTypora"
INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/scripts/install.sh"
export LATEX_TYPORA_SCRIPT_USAGE_PATH="./scripts/install-linux.sh"
export LATEX_TYPORA_INSTALL_SCRIPT_URL="https://raw.githubusercontent.com/${REPO_OWNER}/${REPO_NAME}/main/scripts/install-linux.sh"

resolve_local_install_script() {
    local script_path script_dir

    script_path="${BASH_SOURCE[0]:-$0}"
    if [[ -z "${script_path}" || ! -f "${script_path}" ]]; then
        return 1
    fi

    script_dir="$(cd "$(dirname "${script_path}")" && pwd)"
    [[ -f "${script_dir}/install.sh" ]] || return 1
    printf '%s\n' "${script_dir}/install.sh"
}

download_and_run_install_script() {
    local temp_script status

    command -v curl >/dev/null 2>&1 || {
        echo "Missing required command: curl" >&2
        exit 1
    }
    command -v mktemp >/dev/null 2>&1 || {
        echo "Missing required command: mktemp" >&2
        exit 1
    }

    temp_script="$(mktemp)"
    trap 'rm -f "${temp_script}"' EXIT

    curl -fsSL "${INSTALL_SCRIPT_URL}" -o "${temp_script}"

    status=0
    bash "${temp_script}" "$@" || status=$?
    exit "${status}"
}

if install_script="$(resolve_local_install_script)"; then
    exec "${install_script}" "$@"
fi

download_and_run_install_script "$@"
