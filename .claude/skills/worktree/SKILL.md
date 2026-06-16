---
name: worktree
description: Create an isolated git worktree so two packets can develop in parallel — main session drives packet N while a separate Claude Code window drives packet N+1 in its own branch with no file conflicts.
---

# Worktree — Parallel Packet Execution

Use when you want to build or review packet N+1 while packet N is still in GIT/REPORTER, or when two independent features can run simultaneously.

## Setup

From the repo root (`claude-app-system/`):

```bash
git worktree add ../worktrees/<app>/<branch> -b <branch>
# Example:
git worktree add ../worktrees/getting-money/packet-05-auth -b packet-05-auth
```

Then open a **new Claude Code window** in that path:

```bash
cd ../worktrees/<app>/<branch>
claude
```

That new session has its own context window. It will discover `.claude/settings.json` hooks automatically (Claude Code walks up to find the `.claude/` directory).

## Parallel execution pattern

| Session | Role | Writes to |
|---|---|---|
| **Main** | Coordinator — GIT, REPORTER, MANIFEST updates for packet N | `MANIFEST.json`, `tasks/packet-index.md`, `docs/state.md` |
| **Worktree** | IMPLEMENTER + TESTER + CODE_REVIEWER for packet N+1 | Only the packet's Swift source, tests, design files |

**The worktree session must NOT write to coordinator-owned state files** (`MANIFEST.json`, `tasks/packet-index.md`, `docs/state.md`). It reports its verdict as text; the main session coordinator updates shared state after the main-session packet merges.

## Shared-state conflict rule

The `write-test-results.sh` PostToolUse hook writes to `apps/*/MANIFEST.json` every time `xcodebuild test` finishes. If two sessions run tests simultaneously they will race and one will overwrite the other's verdict.

**Coordination:** finish worktree tests first, then run main-session tests; or skip the hook in the worktree session and let the coordinator manually record the worktree verdict.

## Agent tool shortcut

The Agent tool's `isolation: "worktree"` parameter auto-provisions a git worktree for a spawned subagent without CLI steps. Use this in the coordinator when spawning IMPLEMENTER or TESTER:

```
Agent(isolation: "worktree", subagent_type: "implementer", prompt: "…")
```

The agent works on an isolated copy of the repo on a temporary branch. Changes are preserved (the branch and path are returned) or discarded (if the agent made no changes).

## When NOT to use worktrees

- Packet N+1 depends on a **new model field or schema change** from packet N — the worktree cannot build independently until packet N merges.
- Packets share the same source file — merge conflicts become inevitable.
- The app is on TestFlight with real data and both packets touch the SwiftData schema — run migrations sequentially.

## Teardown

After the worktree branch has been reviewed, merged to main, and pushed:

```bash
# From the repo root:
git worktree remove ../worktrees/<app>/<branch>
# Optional — delete the local and remote branch:
git branch -d <branch>
git push origin --delete <branch>
```

## Listing active worktrees

```bash
git worktree list
```
