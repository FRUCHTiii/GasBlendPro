import Foundation

/// Represents a gas mix composition
/// Supports up to 3 components: Oxygen, Nitrogen, Helium
struct GasMix: Codable, Equatable {
    var oxygen: Double // O2 percentage (0-100)
    var nitrogen: Double // N2 percentage (0-100)
    var helium: Double // He percentage (0-100)

    init(oxygen: Double = 0, nitrogen: Double = 0, helium: Double = 0) {
        self.oxygen = oxygen
        self.nitrogen = nitrogen
        self.helium = helium
    }

    /// Verify that percentages add up to 100 (or close to it)
    var isValid: Bool {
        let total = oxygen + nitrogen + helium
        // Tighter tolerance: 0.2% max error for safety-critical gas mixing
        return total >= 99.9 && total <= 100.1
    }

    /// Total percentage of gas components
    var total: Double {
        oxygen + nitrogen + helium
    }

    /// Check if this is a simple air mix (21% O2, 79% N2)
    var isAir: Bool {
        abs(oxygen - 21.0) < 0.1 && abs(nitrogen - 79.0) < 0.1 && helium < 0.1
    }

    /// Check if this is nitrox (contains O2 and N2, no He)
    var isNitrox: Bool {
        helium < 0.1 && oxygen > 21.0 && nitrogen > 0
    }

    /// Check if this is trimix (contains all three components)
    var isTrimix: Bool {
        oxygen > 0 && nitrogen > 0 && helium > 0.1
    }

    /// Partial pressure of a component at given total pressure
    func partialPressure(component: GasComponent, at totalPressure: Double) -> Double {
        let percentage = switch component {
        case .oxygen: oxygen
        case .nitrogen: nitrogen
        case .helium: helium
        }
        return (totalPressure * percentage) / 100.0
    }

    /// Get pressure needed for a component to reach a target partial pressure
    func pressureToAddForComponent(_ component: GasComponent, targetPartial: Double) -> Double {
        let percentage = switch component {
        case .oxygen: oxygen
        case .nitrogen: nitrogen
        case .helium: helium
        }

        guard percentage > 0 else { return 0 }
        return (targetPartial * 100.0) / percentage
    }
}

enum GasComponent {
    case oxygen
    case nitrogen
    case helium
}

/// Common gas mixes for easy selection
enum CommonGasMixes {
    static let air = GasMix(oxygen: 21.0, nitrogen: 79.0, helium: 0.0)
    static let ean32 = GasMix(oxygen: 32.0, nitrogen: 68.0, helium: 0.0)
    static let ean36 = GasMix(oxygen: 36.0, nitrogen: 64.0, helium: 0.0)
    static let nitrox40 = GasMix(oxygen: 40.0, nitrogen: 60.0, helium: 0.0)

    static let allPresets: [String: GasMix] = [
        "Air": air,
        "EAN32": ean32,
        "EAN36": ean36,
        "Nitrox40": nitrox40
    ]
}
