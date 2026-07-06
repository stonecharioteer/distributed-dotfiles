#!/usr/bin/env bash
set -euo pipefail

status=0

for file in "$@"; do
  [[ -f "$file" ]] || continue
  case "$file" in
    *.yml|*.yaml) ;;
    *) continue ;;
  esac

  python3 - "$file" <<'PY' || status=$?
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
lines = path.read_text().splitlines()
violations = []

for index, line in enumerate(lines):
    command_match = re.match(r"^\s+command:\s+([A-Za-z0-9_.-]+)\s+--version\s*$", line)
    if not command_match:
        continue

    context_start = max(0, index - 4)
    context_end = min(len(lines), index + 8)
    context = lines[context_start:context_end]
    task_name = "\n".join(context[:5]).lower()
    future_context = "\n".join(context).lower()

    is_probe = "- name: check" in task_name
    is_nonfatal = "failed_when: false" in future_context

    if is_probe and not is_nonfatal:
        violations.append(
            f"{path}:{index + 1}: risky direct binary probe: `{line.strip()}`. "
            "Use `shell: command -v tool >/dev/null 2>&1 && tool --version` with `failed_when: false`."
        )

if violations:
    print("\n".join(violations), file=sys.stderr)
    sys.exit(1)
PY
done

exit "$status"
