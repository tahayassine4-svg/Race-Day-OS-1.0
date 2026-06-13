import Foundation
import SwiftData

/// Builds the SwiftData `ModelContainer`. CloudKit is intentionally OFF in v1
/// (local-only), but models are CloudKit-compatible so it can be enabled later.
enum Persistence {
    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(SchemaV1.models)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: [config])
    }

    /// On-disk container at an explicit URL — used by the persistence-survival test
    /// to prove data survives a container release + reopen.
    static func makeContainer(at url: URL) throws -> ModelContainer {
        let schema = Schema(SchemaV1.models)
        let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        return try ModelContainer(for: schema, configurations: [config])
    }
}
