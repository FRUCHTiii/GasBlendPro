import Foundation
import SwiftData
import Testing
@testable import GasBlendPro

@Suite("Persistent Store Upgrade Tests")
@MainActor
struct AppPersistenceTests {
    @Test("Settings from before unit preferences migrate with metric defaults")
    func legacySettingsMigrate() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let configuration = ModelConfiguration(url: directory.appendingPathComponent("default.store"))

        do {
            let schema = Schema([LegacySettings.AppSettings.self, StorageTank.self, GasPreset.self])
            let container = try ModelContainer(for: schema, configurations: [configuration])
            let context = ModelContext(container)
            context.insert(LegacySettings.AppSettings())
            context.insert(GasPreset(name: "Existing trimix", oxygen: 18, helium: 45))
            try context.save()
        }

        let container = try AppPersistence.makeContainer(configuration: configuration)
        let context = ModelContext(container)
        let settings = try #require(context.fetch(FetchDescriptor<AppSettings>()).first)
        #expect(settings.pressureUnit == .bar)
        #expect(settings.temperatureUnit == .celsius)
        #expect(settings.appearanceMode == .dark)
        #expect(settings.defaultTargetPressure == 232)
        #expect(settings.hasAcceptedDisclaimer)
        #expect(try context.fetch(FetchDescriptor<GasPreset>()).first?.name == "Existing trimix")
    }

    @Test("Saved tanks, presets and settings survive reopening the store")
    func savedDataSurvivesReopening() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let configuration = ModelConfiguration(url: directory.appendingPathComponent("default.store"))

        do {
            let container = try AppPersistence.makeContainer(configuration: configuration)
            let context = ModelContext(container)
            context.insert(StorageTank(
                name: "Oxygen bank", gasType: .oxygen, currentPressure: 180,
                maxPressure: 200, tankVolume: 50
            ))
            context.insert(GasPreset(name: "My mix", oxygen: 18, helium: 45))
            let settings = AppSettings(pressureUnit: .psi)
            settings.hasAcceptedDisclaimer = true
            context.insert(settings)
            try context.save()
        }

        let reopened = try AppPersistence.makeContainer(configuration: configuration)
        let context = ModelContext(reopened)
        let tanks = try context.fetch(FetchDescriptor<StorageTank>())
        let presets = try context.fetch(FetchDescriptor<GasPreset>())
        let settings = try context.fetch(FetchDescriptor<AppSettings>())
        #expect(tanks.count == 1)
        #expect(tanks.first?.currentPressure == 180)
        #expect(presets.first?.name == "My mix")
        #expect(presets.first?.helium == 45)
        #expect(settings.first?.pressureUnit == .psi)
        #expect(settings.first?.hasAcceptedDisclaimer == true)
    }

    @Test("An unreadable store reports failure without deleting its contents")
    func unreadableStoreIsPreserved() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let storeURL = directory.appendingPathComponent("default.store")
        let originalData = Data("Unreadable store retained for recovery".utf8)
        try originalData.write(to: storeURL)

        #expect(throws: (any Error).self) {
            try AppPersistence.makeContainer(configuration: ModelConfiguration(url: storeURL))
        }
        #expect(try Data(contentsOf: storeURL) == originalData)
    }
}

private enum LegacySettings {
    @Model
    final class AppSettings {
        var id: UUID
        var topUpGasRawValue: String
        var appearanceModeRawValue: String
        var defaultCurrentOxygen: Double = 21
        var defaultCurrentHelium: Double = 0
        var defaultTargetOxygen: Double = 32
        var defaultTargetHelium: Double = 0
        var defaultTargetPressure: Double = 232
        var hasAcceptedDisclaimer: Bool = true
        var lastModified: Date

        init() {
            id = UUID()
            topUpGasRawValue = TopUpGas.air.rawValue
            appearanceModeRawValue = AppearanceMode.dark.rawValue
            lastModified = Date()
        }
    }
}
