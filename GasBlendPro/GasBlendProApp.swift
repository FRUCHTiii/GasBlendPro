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
    @Environment(\.scenePhase)
    private var scenePhase

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            StorageTank.self,
            GasPreset.self,
            AppSettings.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If migration fails, try deleting and recreating the container
            NSLog("ModelContainer creation failed: \(error)")
            NSLog("Attempting to reset model container...")

            // Get the store URL and delete it
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            let shmURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-shm")
            let walURL = storeURL.deletingPathExtension().appendingPathExtension("sqlite-wal")
            try? FileManager.default.removeItem(at: shmURL)
            try? FileManager.default.removeItem(at: walURL)

            // Try again
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                // App is going to background - clear session
                clearSession()
            }
        }
    }

    private func clearSession() {
        UserDefaults.standard.removeObject(forKey: "session.currentOxygen")
        UserDefaults.standard.removeObject(forKey: "session.currentHelium")
        UserDefaults.standard.removeObject(forKey: "session.currentPressure")
        UserDefaults.standard.removeObject(forKey: "session.targetOxygen")
        UserDefaults.standard.removeObject(forKey: "session.targetHelium")
        UserDefaults.standard.removeObject(forKey: "session.targetPressure")
        UserDefaults.standard.removeObject(forKey: "session.tankVolume")
        UserDefaults.standard.removeObject(forKey: "session.resultJSON")
        UserDefaults.standard.set(false, forKey: "session.hasActiveSession")
    }
}
