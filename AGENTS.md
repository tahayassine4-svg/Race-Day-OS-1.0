# Codex Entrypoint

This repo is an **iOS App Factory**: a reusable, app-agnostic AI orchestration system for building native iOS apps.

The shared source of truth for both Codex and Claude Code is [`WORKFLOW.md`](./WORKFLOW.md). Read it first and follow it exactly.

Codex should then read the active phase's definition per WORKFLOW.md's Agent Roster (a coordinator prompt in `prompts/` or a `.claude/agents/` subagent), the listed `knowledge/` files, and the active app's docs/packet before acting.

Important:

- The first line of every response must be `**Phase: [NAME]**`.
- Never advance past a gate without Yassine's explicit approval.
- When continuing work from Claude, read the active app's `docs/state.md`, `docs/handoff.md` if present, latest relevant report, active packet, and `git status --short`.
- Keep root system files app-agnostic. App-specific work belongs under `apps/<name>/`.

