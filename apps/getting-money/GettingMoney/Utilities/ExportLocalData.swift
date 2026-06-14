import Foundation

/// App-data administration for beta utilities (Packet 08): inspect activity,
/// reset local data, and export a JSON snapshot. Kept behind a protocol so the
/// Settings view model stays testable and free of SwiftData.
@MainActor
protocol LocalDataAdmin: AnyObject {
    func hasAnyActivity() throws -> Bool
    func resetAllLocalData() throws
    func exportSnapshotData() throws -> Data
}

/// Codable snapshot of all local data — a human-readable JSON for beta testers.
struct GMExportSnapshot: Codable, Equatable {
    struct Entry: Codable, Equatable {
        let date: Date
        let exercise: String
        let count: Int
    }
    struct DebtRow: Codable, Equatable {
        let exercise: String
        let repsOwed: Int
    }
    struct TargetRow: Codable, Equatable {
        let exercise: String
        let reps: Int
    }

    var exportedAt: Date
    var appVersion: String
    var repValue: Int
    var bankBalance: Int
    var entries: [Entry]
    var debts: [DebtRow]
    var targets: [TargetRow]

    func encoded() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(self)
    }
}
