import Foundation
import SwiftUI

/// Drives the Settings exercise list. Holds an injected repository (protocol),
/// maps models to lightweight display rows so the View stays dumb.
@Observable
@MainActor
final class SettingsViewModel {
    struct Row: Identifiable {
        let id: String          // exercise key
        let name: String
        let glyph: String
        let target: Int
        let isOptional: Bool
        var isEnabled: Bool
        let cap: Int?

        var isEditable: Bool { isEnabled || !isOptional }
    }

    private(set) var rows: [Row] = []
    private(set) var autoProgressionEnabled = true
    private(set) var progressionAmount = 5
    private(set) var progressionIntervalDays = 14
    private(set) var pullupCap = 10
    private(set) var daysUntilNextProgression = 14
    private(set) var errorMessage: String?

    var showResetConfirmation = false
    private(set) var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"

    private let repository: any ExerciseRepositoryProtocol
    private let progressionEngine: any TargetProgressionEngineProtocol
    private weak var dataAdmin: (any LocalDataAdmin)?

    init(
        repository: any ExerciseRepositoryProtocol,
        progressionEngine: any TargetProgressionEngineProtocol = TargetProgressionEngine(),
        dataAdmin: (any LocalDataAdmin)? = nil
    ) {
        self.repository = repository
        self.progressionEngine = progressionEngine
        self.dataAdmin = dataAdmin
    }

    func load() {
        do {
            let settings = try repository.appSettings()
            autoProgressionEnabled = settings.autoProgressionEnabled
            progressionAmount = settings.progressionAmount
            progressionIntervalDays = settings.progressionIntervalDays
            pullupCap = settings.pullupCap
            daysUntilNextProgression = progressionEngine.daysUntilNextProgression(
                lastProgressionDate: settings.lastProgressionDate,
                intervalDays: settings.progressionIntervalDays,
                today: Date()
            )

            rows = try repository.allOrdered().map { ex in
                Row(
                    id: ex.key,
                    name: ex.name,
                    glyph: ex.glyph,
                    target: repository.currentTarget(for: ex, on: Date()),
                    isOptional: ex.isOptional,
                    isEnabled: ex.isEnabled,
                    cap: ex.key == "pullups" ? settings.pullupCap : nil
                )
            }
            errorMessage = nil
        } catch {
            rows = []
            errorMessage = "Settings could not load."
        }
    }

    func setEnabled(_ key: String, _ enabled: Bool) {
        do {
            try repository.setEnabled(key: key, enabled)
            load()
        } catch {
            errorMessage = "Setting could not be saved."
        }
    }

    func adjustTarget(_ key: String, by delta: Int) {
        guard let row = rows.first(where: { $0.id == key }), row.isEditable else { return }

        do {
            try repository.setTarget(
                key: key,
                reps: max(0, row.target + delta),
                effectiveDate: Date(),
                isManualOverride: true
            )
            load()
        } catch {
            errorMessage = "Target could not be saved."
        }
    }

    func setTarget(_ key: String, reps: Int) {
        do {
            try repository.setTarget(
                key: key,
                reps: max(0, reps),
                effectiveDate: Date(),
                isManualOverride: true
            )
            load()
        } catch {
            errorMessage = "Target could not be saved."
        }
    }

    func setAutoProgressionEnabled(_ enabled: Bool) {
        do {
            try repository.setAutoProgressionEnabled(enabled)
            load()
        } catch {
            errorMessage = "Auto-progression could not be saved."
        }
    }

    func adjustProgressionAmount(by delta: Int) {
        do {
            try repository.setProgressionAmount(progressionAmount + delta)
            load()
        } catch {
            errorMessage = "Progression amount could not be saved."
        }
    }

    func adjustProgressionIntervalDays(by delta: Int) {
        do {
            try repository.setProgressionIntervalDays(progressionIntervalDays + delta)
            load()
        } catch {
            errorMessage = "Progression timing could not be saved."
        }
    }

    func adjustPullupCap(by delta: Int) {
        do {
            try repository.setPullupCap(pullupCap + delta)
            load()
        } catch {
            errorMessage = "Pull-up cap could not be saved."
        }
    }

    // MARK: Beta data utilities (Packet 08)

    func exportData() -> Data? {
        do {
            return try dataAdmin?.exportSnapshotData()
        } catch {
            errorMessage = "Export failed."
            return nil
        }
    }

    func resetAllData() {
        do {
            try dataAdmin?.resetAllLocalData()
            load()
        } catch {
            errorMessage = "Reset failed."
        }
    }

    func applyDueProgression(today: Date = Date()) {
        do {
            let settings = try repository.appSettings()
            var changed = false

            for exercise in try repository.allOrdered() where exercise.isEnabled {
                let record = repository.currentTargetRecord(for: exercise, on: today)
                let result = progressionEngine.progressedTarget(for: TargetProgressionInput(
                    exerciseKey: exercise.key,
                    currentReps: record?.reps ?? 0,
                    isManualOverride: record?.isManualOverride ?? false,
                    autoProgressionEnabled: settings.autoProgressionEnabled,
                    progressionAmount: settings.progressionAmount,
                    progressionIntervalDays: settings.progressionIntervalDays,
                    pullupCap: settings.pullupCap,
                    lastProgressionDate: settings.lastProgressionDate,
                    today: today
                ))

                if result.didProgress {
                    try repository.setTarget(
                        key: exercise.key,
                        reps: result.reps,
                        effectiveDate: today,
                        isManualOverride: false
                    )
                    changed = true
                }
            }

            if changed {
                try repository.markProgressionRun(on: today)
            }

            load()
        } catch {
            errorMessage = "Auto-progression could not run."
        }
    }
}
