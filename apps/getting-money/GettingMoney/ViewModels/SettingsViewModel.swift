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
    }

    private(set) var rows: [Row] = []
    private(set) var errorMessage: String?
    private let repository: any ExerciseRepositoryProtocol

    init(repository: any ExerciseRepositoryProtocol) {
        self.repository = repository
    }

    func load() {
        do {
            rows = try repository.allOrdered().map { ex in
            Row(id: ex.key, name: ex.name, glyph: ex.glyph,
                target: repository.currentTarget(for: ex, on: Date()),
                isOptional: ex.isOptional, isEnabled: ex.isEnabled)
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
}
