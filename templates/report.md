# Packet {{NN}} Report: {{Name}}

## Status: PASSED / FAILED / PARTIAL

## What was built
{{files created/modified}}

## Test results
- {{test}}: PASS / FAIL
- Migration/data-safety test: PASS / FAIL / N/A
- Visual verification vs mockup: PASS / FAIL / N/A

## Review results
- SwiftUI/UI quality: PASS / FAIL — {{notes}}
- Architecture (MVVM-C, DI, no DB in views): PASS / FAIL — {{notes}}
- Security (secrets, auth, input, privacy): PASS / FAIL — {{notes}}
- Regression check: PASS / FAIL — {{notes}}

## Acceptance criteria
- [x] {{met}}
- [ ] {{unmet — reason}}

## Issues found
{{bugs, edge cases, concerns}}

## Trade-offs made
{{shortcuts / decisions worth flagging}}

## Git
- Branch: {{packet-NN-slug}}
- Commit: {{hash}}
- TestFlight/deploy: {{url or "not yet"}}

## Retry count
{{N of 3}}

## Next packet preview
{{what Packet N+1 will build}}
