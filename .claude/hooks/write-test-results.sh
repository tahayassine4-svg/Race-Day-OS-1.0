#!/bin/bash
# PostToolUse: after TESTER runs `xcodebuild test` / `swift test`, parse the
# output and write a PASS/FAIL verdict (+ counts, best-effort) into the active
# packet's MANIFEST.json.tests block automatically — removes "did the Tester
# remember to update MANIFEST.json" from the report.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

case "$command" in
  *xcodebuild*test*|*"swift test"*) ;;
  *) exit 0 ;;
esac

output=$(echo "$input" | jq -r '.tool_response.stdout // .tool_response.output // (.tool_response | tostring) // ""' 2>/dev/null)

repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
[ -z "$repo_root" ] && exit 0

branch=$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null)

manifest=""
for f in "$repo_root"/apps/*/MANIFEST.json; do
  [ -f "$f" ] || continue
  pb=$(jq -r '.packet_branch // ""' "$f")
  if [ "$pb" = "$branch" ]; then
    manifest="$f"
    break
  fi
done

[ -z "$manifest" ] && exit 0

if echo "$output" | grep -qE '\*\* TEST SUCCEEDED \*\*'; then
  status="PASS"
elif echo "$output" | grep -qE '\*\* TEST FAILED \*\*'; then
  status="FAIL"
elif echo "$output" | grep -qE 'Test run with [0-9]+ tests? in [0-9]+ suites? passed'; then
  status="PASS"
elif echo "$output" | grep -qE 'Test run with [0-9]+ tests? in [0-9]+ suites? failed'; then
  status="FAIL"
else
  exit 0
fi

passed=$(echo "$output" | grep -oE 'Test run with [0-9]+ tests?' | grep -oE '[0-9]+' | tail -1)
failed=$(echo "$output" | grep -oE 'with [0-9]+ failures?' | grep -oE '[0-9]+' | tail -1)

[ -z "$passed" ] && passed="null"
[ -z "$failed" ] && failed="null"

tmp=$(mktemp)
jq --arg status "$status" --argjson passed "$passed" --argjson failed "$failed" \
  '.tests = {status: $status, passed: $passed, failed: $failed}' "$manifest" > "$tmp" \
  && mv "$tmp" "$manifest"

exit 0
