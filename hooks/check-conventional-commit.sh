#!/usr/bin/env bash
set -euo pipefail

if [[ $# -gt 0 ]]; then
  commit_msg_file="$1"
else
  commit_msg_file="$(git rev-parse --git-path COMMIT_EDITMSG)"
fi

subject="$(head -n 1 "${commit_msg_file}")"

conventional_pattern='^(build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test)(\([A-Za-z0-9._/-]+\))?!?: .+'

if [[ ! "${subject}" =~ ${conventional_pattern} ]]; then
  cat >&2 <<'EOF'
Commit message must use Conventional Commits format:

  <type>[optional scope][!]: <description>

Allowed types: build, chore, ci, docs, feat, fix, perf, refactor, revert, style, test
Examples:
  feat(qtile): add workstation keybindings
  fix(ansible): make tmux install idempotent
  chore: update pre-commit hooks
EOF
  exit 1
fi
