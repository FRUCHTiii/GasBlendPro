import Foundation

/// Real gas correction using compressibility factors
/// Implements Z-factor corrections for oxygen and helium at various pressures and temperatures
///
/// References:
/// - NIST Chemistry WebBook (https://webbook.nist.gov/)
/// - "Compressibility of Gases Used in Diving" - Brubakk & Neuman
/// - Real gas behavior data for technical diving applications
enum RealGasCorrection {
    /// Standard temperature for diving calculations (20°C = 293.15 K)
    private static let standardTempCelsius = 20.0
    private static let standardTempKelvin = 293.15

    // MARK: - Compressibility Factor Tables

    /// Oxygen (O₂) compressibility factors at 20°C
    /// Data points: (pressure in bar, Z-factor)
    private static let oxygenZFactors: [(pressure: Double, zFactor: Double)] = [
        (1, 1.000), // Ambient
        (50, 0.995), // Low pressure
        (100, 0.990), // Medium-low
        (150, 0.985), // Medium
        (200, 0.978), // Medium-high
        (250, 0.968), // High
        (300, 0.955), // Very high
        (350, 0.940), // Extreme
        (400, 0.922) // Maximum diving pressure
    ]

    /// Helium (He) compressibility factors at 20°C
    /// Helium behaves closer to ideal gas than oxygen
    private static let heliumZFactors: [(pressure: Double, zFactor: Double)] = [
        (1, 1.000), // Ambient
        (50, 1.003), // Slightly above ideal
        (100, 1.006), // Low pressure
        (150, 1.009), // Medium
        (200, 1.012), // Medium-high
        (250, 1.015), // High
        (300, 1.018), // Very high
        (350, 1.020), // Extreme
        (400, 1.022) // Maximum diving pressure
    ]

    // MARK: - Public API

    /// Calculate the compressibility factor (Z) for a gas at given pressure
    /// - Parameters:
    ///   - gasType: Type of gas (oxygen or helium)
    ///   - pressure: Pressure in bar
    ///   - temperature: Temperature in Celsius (default: 20°C)
    /// - Returns: Compressibility factor Z (dimensionless)
    static func compressibilityFactor(
        for gasType: GasType,
        at pressure: Double,
        temperature: Double = standardTempCelsius
    ) -> Double {
        // Select appropriate Z-factor table
        let zFactorTable: [(pressure: Double, zFactor: Double)]
        switch gasType {
        case .oxygen:
            zFactorTable = oxygenZFactors
        case .helium:
            zFactorTable = heliumZFactors
        case .air:
            // Air is ~21% O₂, 79% N₂
            // N₂ behaves similarly to O₂ at these pressures
            // Use oxygen table as approximation (slightly conservative)
            zFactorTable = oxygenZFactors
        }

        // Get base Z-factor at standard temperature (20°C)
        let zBase = interpolateZFactor(pressure: pressure, table: zFactorTable)

        // Apply temperature correction
        // For real gases: Z increases with temperature at high pressure
        // Simplified linear correction: ~0.1% per °C for oxygen, ~0.05% per °C for helium
        let tempDiff = temperature - standardTempCelsius
        let tempCorrectionFactor: Double
        switch gasType {
        case .oxygen, .air:
            // Oxygen: stronger temperature dependence
            tempCorrectionFactor = 0.001 // 0.1% per °C
        case .helium:
            // Helium: weaker temperature dependence
            tempCorrectionFactor = 0.0005 // 0.05% per °C
        }

        let zCorrected = zBase * (1.0 + tempCorrectionFactor * tempDiff)

        return zCorrected
    }

    /// Calculate real gas volume from ideal gas volume
    /// - Parameters:
    ///   - idealVolume: Volume calculated using ideal gas law (liters)
    ///   - gasType: Type of gas
    ///   - pressure: Pressure in bar
    ///   - temperature: Temperature in Celsius (default: 20°C)
    /// - Returns: Corrected volume accounting for real gas effects (liters)
    static func realVolume(
        fromIdeal idealVolume: Double,
        gasType: GasType,
        pressure: Double,
        temperature: Double = standardTempCelsius
    ) -> Double {
        let z = compressibilityFactor(for: gasType, at: pressure, temperature: temperature)
        // Real volume = Ideal volume / Z
        // (More gas is needed when Z < 1, less when Z > 1)
        return idealVolume / z
    }

    /// Calculate pressure deduction from storage tank using real gas correction
    /// - Parameters:
    ///   - volumeNeeded: Volume needed in liters (at 1 bar)
    ///   - storageTankVolume: Storage tank volume in liters
    ///   - storageTankPressure: Current storage tank pressure in bar
    ///   - gasType: Type of gas in storage tank
    ///   - temperature: Temperature in Celsius (default: 20°C)
    /// - Returns: Pressure deduction from storage tank in bar
    static func pressureDeduction(
        volumeNeeded: Double,
        storageTankVolume: Double,
        storageTankPressure: Double,
        gasType: GasType,
        temperature: Double = standardTempCelsius
    ) -> Double {
        // Correct the volume needed for real gas effects at storage pressure
        let realVolumeNeeded = realVolume(
            fromIdeal: volumeNeeded,
            gasType: gasType,
            pressure: storageTankPressure,
            temperature: temperature
        )

        // Calculate pressure change in storage tank
        return realVolumeNeeded / storageTankVolume
    }

    /// Get correction percentage for display to user
    /// - Parameters:
    ///   - gasType: Type of gas
    ///   - pressure: Pressure in bar
    ///   - temperature: Temperature in Celsius (default: 20°C)
    /// - Returns: Percentage correction (e.g., 2.5 means 2.5% more gas needed)
    static func correctionPercentage(
        for gasType: GasType,
        at pressure: Double,
        temperature: Double = standardTempCelsius
    ) -> Double {
        let z = compressibilityFactor(for: gasType, at: pressure, temperature: temperature)
        return ((1.0 / z) - 1.0) * 100.0
    }

    // MARK: - Private Helpers

    /// Linear interpolation of Z-factor from table
    private static func interpolateZFactor(
        pressure: Double,
        table: [(pressure: Double, zFactor: Double)]
    ) -> Double {
        // Handle edge cases
        guard let first = table.first, let last = table.last else {
            return 1.0 // Default to ideal gas if no data
        }

        if pressure <= first.pressure {
            return first.zFactor
        }

        if pressure >= last.pressure {
            return last.zFactor
        }

        // Find bracketing points
        for i in 0..<(table.count - 1) {
            let lower = table[i]
            let upper = table[i + 1]

            if pressure >= lower.pressure && pressure <= upper.pressure {
                // Linear interpolation
                let fraction = (pressure - lower.pressure) / (upper.pressure - lower.pressure)
                return lower.zFactor + fraction * (upper.zFactor - lower.zFactor)
            }
        }

        // Should never reach here, but return ideal gas as fallback
        return 1.0
    }
}

// MARK: - Gas Behavior Info

/// Information about gas behavior deviation from ideal
struct GasBehaviorInfo {
    let zFactor: Double
    let deviation: Double
    let description: String
}

// MARK: - Extensions

extension RealGasCorrection {
    /// Calculate the deviation from ideal gas behavior
    /// - Parameters:
    ///   - gasType: Type of gas
    ///   - pressure: Pressure in bar
    ///   - temperature: Temperature in Celsius (default: 20°C)
    /// - Returns: Gas behavior information
    static func gasBehaviorInfo(
        for gasType: GasType,
        at pressure: Double,
        temperature: Double = standardTempCelsius
    ) -> GasBehaviorInfo {
        let z = compressibilityFactor(for: gasType, at: pressure, temperature: temperature)
        let deviation = correctionPercentage(for: gasType, at: pressure, temperature: temperature)

        let description: String
        if abs(deviation) < 1.0 {
            description = "Near ideal"
        } else if deviation > 0 {
            description = String(format: "+%.1f%% more gas needed", deviation)
        } else {
            description = String(format: "%.1f%% less gas needed", abs(deviation))
        }

        return GasBehaviorInfo(zFactor: z, deviation: deviation, description: description)
    }
}
