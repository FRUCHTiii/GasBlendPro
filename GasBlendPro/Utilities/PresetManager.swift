import Foundation
import SwiftData

/// Utility for managing gas presets
enum PresetManager {
    /// Initialize default presets if none exist
    static func initializeDefaults(in modelContext: ModelContext, existingPresets: [GasPreset]) {
        // Only add defaults if no presets exist
        if existingPresets.isEmpty {
            for defaultPreset in GasPreset.defaultPresets {
                modelContext.insert(defaultPreset)
            }
        }
    }
}
