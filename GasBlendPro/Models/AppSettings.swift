import Foundation
import SwiftData

enum TopUpGas: String, Codable, CaseIterable {
    case air = "Air (21% O₂)"
    case oxygen = "Pure Oxygen (100% O₂)"
    case ean32 = "EAN32 (32% O₂)"
    case ean36 = "EAN36 (36% O₂)"

    var gasMix: GasMix {
        switch self {
        case .air:
            return GasMix(oxygen: 21.0, nitrogen: 79.0, helium: 0.0)
        case .oxygen:
            return GasMix(oxygen: 100.0, nitrogen: 0.0, helium: 0.0)
        case .ean32:
            return GasMix(oxygen: 32.0, nitrogen: 68.0, helium: 0.0)
        case .ean36:
            return GasMix(oxygen: 36.0, nitrogen: 64.0, helium: 0.0)
        }
    }

    var displayName: String {
        self.rawValue
    }
}

enum AppearanceMode: String, Codable, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var displayName: String {
        self.rawValue
    }
}

@Model
class AppSettings {
    var id: UUID
    var topUpGasRawValue: String
    var appearanceModeRawValue: String
    var lastModified: Date

    init(topUpGas: TopUpGas = .air, appearanceMode: AppearanceMode = .system) {
        self.id = UUID()
        self.topUpGasRawValue = topUpGas.rawValue
        self.appearanceModeRawValue = appearanceMode.rawValue
        self.lastModified = Date()
    }

    var topUpGas: TopUpGas {
        get {
            TopUpGas(rawValue: topUpGasRawValue) ?? .air
        }
        set {
            topUpGasRawValue = newValue.rawValue
            lastModified = Date()
        }
    }

    var appearanceMode: AppearanceMode {
        get {
            AppearanceMode(rawValue: appearanceModeRawValue) ?? .system
        }
        set {
            appearanceModeRawValue = newValue.rawValue
            lastModified = Date()
        }
    }
}
