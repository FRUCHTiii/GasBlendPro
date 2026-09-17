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

    @State private var sharedModelContainer: ModelContainer?
    @State private var storageUnavailable = false

    var body: some Scene {
        WindowGroup {
            Group {
                if let sharedModelContainer {
                    ContentView()
                        .modelContainer(sharedModelContainer)
                } else if storageUnavailable {
                    ContentUnavailableView {
                        Label("Unable to Open Saved Data", systemImage: "externaldrive.badge.exclamationmark")
                    } description: {
                        Text("Your saved data has been kept. Free up storage if needed, then try again.")
                    } actions: {
                        Button("Try Again", action: openStore)
                            .buttonStyle(.borderedProminent)
                    }
                } else {
                    ProgressView("Opening Saved Data")
                }
            }
            .task {
                if sharedModelContainer == nil && !storageUnavailable {
                    openStore()
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                // App is going to background - clear session
                clearSession()
            }
        }
    }

    private func openStore() {
        do {
            sharedModelContainer = try AppPersistence.makeContainer()
            storageUnavailable = false
        } catch {
            NSLog("ModelContainer creation failed: \(error)")
            storageUnavailable = true
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
