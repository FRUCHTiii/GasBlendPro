import SwiftData

enum AppPersistence {
    /// Keep the existing schema and default store location when upgrading the app.
    /// Opening errors must propagate to the UI without replacing the user's store.
    static func makeContainer(configuration: ModelConfiguration? = nil) throws -> ModelContainer {
        let schema = Schema([StorageTank.self, GasPreset.self, AppSettings.self])
        let configuration = configuration ?? ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
