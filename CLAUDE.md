# Claude Code Entrypoint

This repo is an **iOS App Factory**: a reusable, app-agnostic AI orchestration system for building native iOS apps.

The shared source of truth for both Claude Code and Codex is [`WORKFLOW.md`](./WORKFLOW.md). Read it first and follow it exactly.

Claude Code should then read the active agent prompt in `prompts/`, the listed `knowledge/` files, and the active app's docs/packet before acting.

Important:

- The first line of every response must be `**Phase: [NAME]**`.
- Never advance past a gate without Yassine's explicit approval.
- Before handing work to Codex or stopping near a limit, update the active app's `docs/state.md` and, when useful, write `docs/handoff.md` from [`templates/handoff.md`](./templates/handoff.md).
- Keep root system files app-agnostic. App-specific work belongs under `apps/<name>/`.

