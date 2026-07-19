#!/usr/bin/env bash
# Block personal Ansible inventory from being committed to the public repo.
set -euo pipefail

if [[ $# -eq 0 ]]; then
  exit 0
fi

blocked=0

is_allowed_inventory_file() {
  local path="$1"
  case "${path}" in
    inventory/group_vars/*|inventory/host_vars/.gitkeep|inventory/localhost.yml|inventory/ssh-config-example.md)
      return 0
      ;;
    inventory/*.example.yml|inventory/example-*.yml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_public_example_inventory() {
  local path="$1"
  case "${path}" in
    inventory/*.example.yml|inventory/example-*.yml)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

for path in "$@"; do
  [[ "${path}" == inventory/* ]] || continue
  [[ -e "${path}" || -L "${path}" ]] || continue

  if ! is_allowed_inventory_file "${path}"; then
    echo "Blocked personal inventory path: ${path}" >&2
    blocked=1
    continue
  fi

  # Public examples must stay generic.
  if is_public_example_inventory "${path}"; then
    if grep -Eiq '(t14-g2|p1-g2|x13-flow|hp-pavilion|\bEQR5\b|stonecharioteer\.home)' "${path}"; then
      echo "Blocked personal hostname marker in public example inventory: ${path}" >&2
      blocked=1
    fi
  fi
done

if [[ "${blocked}" -ne 0 ]]; then
  cat >&2 <<'EOF'

Personal inventory must stay local.
- Keep real hosts in gitignored inventory/hosts.yml or inventory/my-*.yml
- Commit only generic examples (*.example.yml, example-hosts.yml, localhost.yml)
- Put shared non-secret behavior in inventory/group_vars/
- Put machine-specific private overrides in gitignored inventory/host_vars/
- Public docs/examples should use *.home.local, not personal home-network domains

EOF
  exit 1
fi
