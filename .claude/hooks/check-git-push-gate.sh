#!/bin/bash
# PreToolUse gate: blocks `git push` / `gh pr create` unless the MANIFEST.json
# for the current branch's packet shows tests.status == PASS and
# code_review.status == PASS. Converts "CODE_REVIEWER passes before GIT"
# from a prompt convention into a guaranteed precondition.

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

if ! echo "$command" | grep -qE '\bgit push\b|\bgh pr create\b'; then
  exit 0
fi

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

if [ -z "$manifest" ]; then
  # Fail closed for packet branches: a packet branch with no matching
  # MANIFEST.json.packet_branch means the gate can't verify anything for
  # this packet — most likely packet_branch is stale from the prior
  # packet. Non-packet branches (main, etc.) are left ungated.
  case "$branch" in
    packet-*)
      echo "BLOCKED: no apps/*/MANIFEST.json has packet_branch == \"$branch\". Update that app's MANIFEST.json.packet_branch to this branch (and set tests.status/code_review.status to \"PASS\") before pushing or opening a PR." >&2
      exit 2
      ;;
    *)
      exit 0
      ;;
  esac
fi

tests_status=$(jq -r '.tests.status // ""' "$manifest")
review_status=$(jq -r '.code_review.status // ""' "$manifest")

if [ "$tests_status" != "PASS" ] || [ "$review_status" != "PASS" ]; then
  echo "BLOCKED: $manifest shows tests.status=\"$tests_status\", code_review.status=\"$review_status\" for branch \"$branch\". Both must be \"PASS\" before pushing or opening a PR." >&2
  exit 2
fi

exit 0
