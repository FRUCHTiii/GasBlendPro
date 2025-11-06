import Foundation
import SwiftData

@Model
class GasPreset {
    var id: UUID
    var name: String
    var oxygen: Double
    var helium: Double
    var createdAt: Date

    init(name: String, oxygen: Double, helium: Double) {
        self.id = UUID()
        self.name = name
        // Clamp oxygen and helium to valid ranges
        self.oxygen = max(0, min(100, oxygen))
        self.helium = max(0, min(100, helium))
        self.createdAt = Date()
    }

    var gasMix: GasMix {
        GasMix(
            oxygen: oxygen,
            nitrogen: max(0, 100.0 - oxygen - helium),
            helium: helium
        )
    }

    // Default presets (shipped with the app, but user can delete them)
    static let defaultPresets: [GasPreset] = [
        GasPreset(name: "Air", oxygen: 21.0, helium: 0.0),
        GasPreset(name: "Nitrox32", oxygen: 32.0, helium: 0.0),
        GasPreset(name: "Nitrox50", oxygen: 50.0, helium: 0.0),
        GasPreset(name: "Trimix21/35", oxygen: 21.0, helium: 35.0),
        GasPreset(name: "Trimix18/45", oxygen: 18.0, helium: 45.0),
        GasPreset(name: "Trimix15/55", oxygen: 15.0, helium: 55.0),
        GasPreset(name: "Trimix12/65", oxygen: 12.0, helium: 65.0),
        GasPreset(name: "Trimix10/70", oxygen: 10.0, helium: 70.0),
        GasPreset(name: "Triox30/30", oxygen: 30.0, helium: 30.0)
    ]
}
