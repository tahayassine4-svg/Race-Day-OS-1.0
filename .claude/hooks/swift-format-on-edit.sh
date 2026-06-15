#!/bin/bash
# PostToolUse: after Edit/Write touches a .swift file, run `swift format` on it
# in-place. Removes "did the implementer format correctly" from CODE_REVIEWER's
# job — formatting is enforced deterministically, not by prompt convention.

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

case "$file_path" in
  *.swift) ;;
  *) exit 0 ;;
esac

[ -f "$file_path" ] || exit 0

swift format format --in-place "$file_path" 2>/dev/null

exit 0
