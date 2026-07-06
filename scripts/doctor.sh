#!/usr/bin/env bash
set -euo pipefail

section() {
  printf '\n==> %s\n' "$1"
}

check_command() {
  local name="$1"
  if command -v "${name}" >/dev/null 2>&1; then
    printf '✓ %-18s %s\n' "${name}" "$(command -v "${name}")"
  else
    printf '✗ %-18s missing\n' "${name}"
  fi
}

section "System"
printf 'OS:      %s\n' "$(uname -s)"
printf 'Arch:    %s\n' "$(uname -m)"
printf 'User:    %s\n' "${USER:-unknown}"
printf 'Home:    %s\n' "${HOME:-unknown}"

if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  printf 'Distro:  %s\n' "${PRETTY_NAME:-unknown}"
elif [[ "$(uname -s)" == "Darwin" ]]; then
  printf 'macOS:   %s\n' "$(sw_vers -productVersion 2>/dev/null || echo unknown)"
fi

section "Required CLIs"
check_command git
check_command ansible
check_command ansible-playbook
check_command ansible-lint
check_command pre-commit

section "Platform package manager"
case "$(uname -s)" in
  Darwin)
    check_command brew
    ;;
  Linux)
    if command -v apt-get >/dev/null 2>&1; then
      check_command apt-get
    elif command -v pacman >/dev/null 2>&1; then
      check_command pacman
    else
      printf '✗ supported package manager missing\n'
    fi
    ;;
  *)
    printf '⚠ unsupported OS for this repo\n'
    ;;
esac

section "GitHub access"
if command -v gh >/dev/null 2>&1; then
  gh auth status || true
else
  printf '⚠ gh is not installed; GitHub preflight roles may install it on Linux.\n'
fi

section "Repository shortcuts"
printf 'Headless Linux: ./bootstrap headless --host <ssh-host> --user <user>\n'
printf 'Linux GUI:      ./bootstrap gui --host <ssh-host> --user <user>\n'
printf 'macOS base:     ./bootstrap mac\n'
printf 'macOS GUI:      ./bootstrap mac-gui\n'

section "Inventory examples"
printf 'Headless: inventory/headless.example.yml\n'
printf 'GUI:      inventory/gui.example.yml\n'
printf 'macOS:    inventory/mac.example.yml\n'
