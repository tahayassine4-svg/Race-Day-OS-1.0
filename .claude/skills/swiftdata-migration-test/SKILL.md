---
name: swiftdata-migration-test
description: Recipe for proving a SwiftData schema/persistence change cannot wipe a shipped app's existing data. Use whenever the active packet adds, renames, removes, or retypes a @Model property, or changes a SchemaMigrationPlan, on an app with real TestFlight/App Store users.
---

# SwiftData Migration Test — data-safety recipe

This skill is the TESTER's mandatory check whenever a packet changes persistence
on a shipped app. A schema change is **guilty until proven innocent**. A passing
build does NOT prove data safety. A Swift default value is NOT a store-level default.

## The required test

1. Build a store using the **previous shipped schema** (`VersionedSchema` / the
   prior `@Model` shape) — not the new one.
2. Insert representative real data (rows that look like what's actually on a
   user's device today).
3. Reopen that same store with the **new schema + the `SchemaMigrationPlan`**.
4. Assert **every record survives** and any new fields default cleanly.

If the old-schema store cannot migrate, that is a **FAILED** criterion — shipping
it would wipe users.

```swift
@Test("v1 store with real dives migrates to v2 without data loss")
func migratesV1ToV2() throws {
    // 1. Build a v1 store and insert v1-shaped data.
    let v1Container = try ModelContainer(
        for: DiveSchemaV1.Dive.self,
        configurations: .init(url: tempURL, schema: Schema([DiveSchemaV1.Dive.self], version: DiveSchemaV1.versionIdentifier))
    )
    let v1Context = v1Container.mainContext
    v1Context.insert(DiveSchemaV1.Dive(date: .now, depth: 18.2))
    try v1Context.save()

    // 2. Reopen with v2 schema + migration plan.
    let v2Container = try ModelContainer(
        for: DiveSchemaV2.Dive.self,
        migrationPlan: DiveMigrationPlan.self,
        configurations: .init(url: tempURL, schema: Schema([DiveSchemaV2.Dive.self], version: DiveSchemaV2.versionIdentifier))
    )

    // 3. Assert every record survived and new fields defaulted cleanly.
    let dives = try v2Container.mainContext.fetch(FetchDescriptor<DiveSchemaV2.Dive>())
    #expect(dives.count == 1)
    #expect(dives[0].tags == [])
}
```

## Constraints from CloudKit-synced stores

- SwiftData migrations use `VersionedSchema` + `SchemaMigrationPlan` (lightweight
  for additive changes, custom stages otherwise).
- **CloudKit-synced stores are add-only:** you may add optional fields; you may
  not rename/delete destructively. Design models so new fields are optional or
  have defaults.

## Reporting

If this test fails, the verdict is FAILED regardless of how other acceptance
criteria score — note explicitly that shipping as-is would wipe existing
TestFlight/App Store users' data.
