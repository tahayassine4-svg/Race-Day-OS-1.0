# Agent Handoff

Use this when Claude Code hands work to Codex, Codex hands work back to Claude Code, or either agent stops near a context/usage limit.

## Current Goal
{{One sentence describing what the next agent should achieve.}}

## Active Context
- App: `{{apps/<app-name>}}`
- Phase: `{{SESSION_INIT|ARCHITECT|PLANNER|DESIGNER|IMPLEMENTER|TESTER|UI_REVIEWER|CODE_REVIEWER|GIT|REPORTER|DEPLOYER|ICP}}`
- Packet: `{{NN — packet name}}`
- Branch: `{{branch or —}}`
- Last commit: `{{commit hash or —}}`

## Last Completed Action
{{What was just finished. Be concrete.}}

## Files Changed
- `{{path/to/file}}` — {{what changed and why}}

## Tests And Verification
- Run: `{{command}}` — {{PASS/FAIL and key result}}
- Not run: `{{command or verification}}` — {{why not}}
- Visual artifacts: `{{path/to/screenshot-or-report}}`

## Known Risks
- {{Risk, uncertainty, or edge case the next agent should keep in mind.}}

## Blockers
- {{Blocker or "None."}}

## Next Recommended Step
{{The exact next action or command the next agent should take.}}

## Build / Archive Status
- Latest tested build includes these changes: `{{yes/no}}`
- Latest archive includes these changes: `{{yes/no}}`
- Latest IPA path: `{{path or —}}`

## Notes For Next Agent
{{Anything that would prevent the next agent from wasting time or repeating work.}}

