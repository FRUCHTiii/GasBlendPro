//
//  GasBlendProApp.swift
//  GasBlendPro
//
//  Created by Johannes Six on 05.11.25.
//

import SwiftUI
import SwiftData

@main
struct GasBlendProApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StorageTank.self,
            GasPreset.self,
            AppSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
