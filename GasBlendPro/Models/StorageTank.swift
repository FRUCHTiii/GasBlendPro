import Foundation
import SwiftData

/// Represents a gas storage cylinder
@Model
final class StorageTank: Identifiable {
    @Attribute(.unique)
    var id: UUID
    var name: String
    var gasType: GasType // O2, He, or Air
    var currentPressure: Double // bar
    var maxPressure: Double // bar (tank's rated maximum pressure)
    var tankVolume: Double // liters
    var purity: Double // percentage (0-100)
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        gasType: GasType,
        currentPressure: Double,
        maxPressure: Double,
        tankVolume: Double,
        purity: Double = 100.0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.gasType = gasType
        self.currentPressure = currentPressure
        self.maxPressure = maxPressure
        self.tankVolume = tankVolume
        self.purity = purity
        self.createdAt = createdAt
    }

    /// Calculate percentage of tank capacity used
    var percentageFilled: Double {
        guard maxPressure > 0 else { return 0 }
        return (currentPressure / maxPressure) * 100.0
    }

    /// Check if tank has enough gas for the requested volume
    /// - Parameters:
    ///   - volumeNeeded: Volume needed in liters (at 1 bar)
    ///   - temperature: Gas temperature in Celsius (default: 20°C)
    /// - Returns: True if tank has sufficient gas
    func hasEnoughGas(volumeNeeded: Double, temperature: Double = 20.0) -> Bool {
        let pressureNeeded = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: tankVolume,
            storageTankPressure: currentPressure,
            gasType: gasType,
            temperature: temperature
        )
        return currentPressure >= pressureNeeded
    }

    /// Get the gas mix for this storage tank
    var gasMix: GasMix {
        let adjustedPurity = purity / 100.0
        switch gasType {
        case .oxygen:
            return GasMix(
                oxygen: 100.0 * adjustedPurity,
                nitrogen: 0.0,
                helium: 0.0
            )
        case .helium:
            return GasMix(
                oxygen: 0.0,
                nitrogen: 0.0,
                helium: 100.0 * adjustedPurity
            )
        case .air:
            return GasMix(
                oxygen: 21.0 * adjustedPurity,
                nitrogen: 79.0 * adjustedPurity,
                helium: 0.0
            )
        }
    }

    /// Get human-readable gas type label
    var gasTypeLabel: String {
        gasType.rawValue
    }

    /// Calculate how much of this gas is needed
    /// - Parameter pressure: Pressure to be added from this tank
    /// - Returns: Volume of gas that will be used
    func volumeForPressure(_ pressure: Double) -> Double {
        pressure * tankVolume
    }

    /// Deduct used gas from tank based on volume consumed (with real gas correction)
    /// - Parameters:
    ///   - volumeUsed: Volume of gas consumed in liters (at 1 bar)
    ///   - temperature: Gas temperature in Celsius (default: 20°C)
    func deductUsage(volumeUsed: Double, temperature: Double = 20.0) {
        // Use real gas correction for accurate pressure deduction
        let pressureChange = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeUsed,
            storageTankVolume: tankVolume,
            storageTankPressure: currentPressure,
            gasType: gasType,
            temperature: temperature
        )
        currentPressure = max(0, currentPressure - pressureChange)
    }
}

enum GasType: String, Codable {
    case oxygen = "Oxygen"
    case helium = "Helium"
    case air = "Air"
}
