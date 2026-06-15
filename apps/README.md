# apps/

Each app the factory builds lives here, fully self-contained:

```
apps/<app-name>/
├── docs/     vision.md · stack.md · ui-system.md · decisions.md · state.md · icp.md
├── tasks/    packet-index.md · packet-NN.md
├── design/   packet-NN.html + packet-NN.png  (approved mockups)
├── reports/  packet-NN-report.md · icp-session-*.md
└── <Xcode project + Swift source>
```

The Architect scaffolds a new app here from `../../templates/`. The system files in the repo root stay app-agnostic — nothing app-specific belongs outside this folder.

(The pre-existing apps `GettinMoney/`, `project-tracker-ios/`, `calisthenics-rep-tracker-ios/` are still at the repo root and can be moved in here manually later.)
