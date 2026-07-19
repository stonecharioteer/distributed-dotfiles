#!/usr/bin/env bash
# Rewrite personal home-network FQDNs to generic local examples in staged files.
# Exits non-zero when files are modified so pre-commit can re-stage them.
set -euo pipefail

if [[ $# -eq 0 ]]; then
  exit 0
fi

# Build markers without embedding the full personal suffix literally in one token
# in ways that would cause this fixer to rewrite itself.
personal_suffix="home.$(printf '%s' 'arpa')"
public_suffix="home.local"
personal_regex="[[:alnum:]._-]+\\.${personal_suffix//./\\.}"

changed=0

for path in "$@"; do
  [[ -f "${path}" ]] || continue
  [[ -s "${path}" ]] || continue

  # Never rewrite this fixer or other hook implementations.
  case "${path}" in
    hooks/*) continue ;;
  esac

  # Skip binary files.
  if ! grep -Iq . "${path}" 2>/dev/null; then
    continue
  fi

  # Leave gitignored personal inventory alone if it somehow gets passed in.
  case "${path}" in
    inventory/hosts.yml|inventory/my-*.yml|inventory/home.yml|inventory/personal.yml|inventory/production.yml|inventory/host_vars/*)
      continue
      ;;
  esac

  if grep -Eq "${personal_regex}" "${path}"; then
    tmp="$(mktemp)"
    sed -E "s/([[:alnum:]._-]+)\\.${personal_suffix//./\\.}/\\1.${public_suffix}/g" "${path}" >"${tmp}"
    if ! cmp -s "${path}" "${tmp}"; then
      mv "${tmp}" "${path}"
      echo "Anonymized *.${personal_suffix} -> *.${public_suffix} in ${path}"
      changed=1
    else
      rm -f "${tmp}"
    fi
  fi
done

if [[ "${changed}" -ne 0 ]]; then
  cat >&2 <<EOF

Replaced personal *.${personal_suffix} hostnames with *.${public_suffix}.
Re-stage the modified files and commit again.
Keep real ${personal_suffix} names only in gitignored local inventory.
EOF
  exit 1
fi
