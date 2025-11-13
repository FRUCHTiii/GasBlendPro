import Foundation

/// Constants for air composition and validation limits
private enum BlendingConstants {
    static let airOxygenFraction = 0.21
    static let airNitrogenFraction = 0.79
    static let maxPressure = 400.0 // bar - reasonable maximum for diving cylinders
    static let epsilon = 1e-10 // tolerance for floating-point comparisons
}

/// Input parameters for blending calculation
struct BlendingInput {
    let currentMix: GasMix
    let currentPressure: Double
    let targetMix: GasMix
    let targetPressure: Double
    let topupMix: GasMix
    let tankVolume: Double

    var isValid: Bool {
        currentPressure >= 0 && currentPressure <= BlendingConstants.maxPressure &&
        targetPressure > 0 && targetPressure <= BlendingConstants.maxPressure &&
        targetPressure >= currentPressure &&
        currentMix.isValid && targetMix.isValid && topupMix.isValid &&
        tankVolume > 0 && tankVolume <= 50
    }
}

/// Result components for building final blending result
private struct BlendingResultComponents {
    let heToAdd: Double
    let actualO2ToAdd: Double
    let actualAirToAdd: Double
    let heVolume: Double
    let o2Volume: Double
    let pressureAfterHe: Double
    let finalPressure: Double
    let airToRelease: Double
    let pressureAfterRelease: Double
    let finalMix: GasMix
}

/// Result of a blending calculation
struct BlendingResult: Codable, Equatable {
    /// Helium pressure to add (bar)
    let heliumToAdd: Double

    /// Oxygen pressure to add (bar)
    let oxygenToAdd: Double

    /// Air pressure to add (bar)
    let airToAdd: Double

    /// Oxygen volume used (liters)
    let oxygenVolume: Double

    /// Helium volume used (liters)
    let heliumVolume: Double

    /// Intermediate pressure after adding helium (bar)
    let pressureAfterHelium: Double

    /// Intermediate pressure after adding air (bar)
    let pressureAfterAir: Double

    /// Intermediate pressure after adding oxygen (bar)
    let pressureAfterOxygen: Double

    /// Air pressure to release (bar) - if positive, must release air first
    let airToRelease: Double

    /// Pressure after releasing air (bar)
    let pressureAfterRelease: Double

    /// Final mix achieved
    let finalMix: GasMix

    var isValid: Bool {
        // All gas amounts must be non-negative (physically impossible to add negative gas)
        oxygenToAdd >= 0 && airToAdd >= 0 && heliumToAdd >= 0
    }
}

/// Handles all gas blending calculations
class BlendingCalculator {
    /// Validate that pressure values are finite and non-negative
    private static func validatePressures(_ pressures: Double...) -> Bool {
        pressures.allSatisfy { $0.isFinite && $0 >= 0 }
    }

    /// Find optimal pressure for oxygen reduction using binary search
    private static func findOptimalPressureForO2Reduction(
        currentPressure: Double,
        currentMix: GasMix,
        targetO2Partial: Double,
        targetN2Partial: Double
    ) -> Double? {
        guard currentPressure.isFinite && currentPressure > 0 else { return nil }

        func canBlendAtPressure(_ testPressure: Double) -> Bool {
            let testO2Partial = (testPressure * currentMix.oxygen) / 100.0
            let testN2Partial = (testPressure * currentMix.nitrogen) / 100.0
            let n2ToAdd = targetN2Partial - testN2Partial
            let airToAdd = n2ToAdd / BlendingConstants.airNitrogenFraction
            let o2FromAir = airToAdd * BlendingConstants.airOxygenFraction
            let totalO2AfterAir = testO2Partial + o2FromAir
            return totalO2AfterAir <= (targetO2Partial + 0.01)
        }

        var lowPressure = 0.1
        var highPressure = currentPressure
        var optimalPressure = currentPressure
        var iterations = 0

        while highPressure - lowPressure > 0.1 {
            iterations += 1
            guard iterations <= 100 else { return nil }

            let midPressure = (lowPressure + highPressure) / 2.0
            guard midPressure.isFinite && midPressure > 0 else { return nil }

            if canBlendAtPressure(midPressure) {
                optimalPressure = midPressure
                lowPressure = midPressure
            } else {
                highPressure = midPressure
            }
        }

        return canBlendAtPressure(optimalPressure) ? optimalPressure : nil
    }

    /// Calculate actual air and oxygen amounts considering constraints
    private static func calculateFinalGasAmounts(
        startingPressure: Double,
        startingO2Partial: Double,
        currentMix: GasMix,
        targetO2Partial: Double,
        targetN2Partial: Double
    ) -> (airToAdd: Double, o2ToAdd: Double)? {
        let currentN2Partial = (startingPressure * currentMix.nitrogen) / 100.0
        let n2ToAdd = targetN2Partial - currentN2Partial
        let airToAdd = n2ToAdd / BlendingConstants.airNitrogenFraction

        let o2FromAir = airToAdd * BlendingConstants.airOxygenFraction
        var actualAirToAdd = airToAdd
        var actualO2ToAdd = targetO2Partial - startingO2Partial - o2FromAir

        if actualO2ToAdd < -0.01 {
            let maxAirForO2 = (targetO2Partial - startingO2Partial) / BlendingConstants.airOxygenFraction
            let minAirForN2 = n2ToAdd / BlendingConstants.airNitrogenFraction

            guard maxAirForO2 >= minAirForN2 else { return nil }

            actualAirToAdd = minAirForN2
            let o2FromMinAir = minAirForN2 * BlendingConstants.airOxygenFraction
            actualO2ToAdd = targetO2Partial - startingO2Partial - o2FromMinAir
        } else {
            actualO2ToAdd = max(0, actualO2ToAdd)
        }

        return (actualAirToAdd, actualO2ToAdd)
    }

    /// Calculate blending for an empty bottle
    private static func calculateEmptyBottleBlend(
        targetMix: GasMix,
        targetPressure: Double,
        tankVolume: Double
    ) -> BlendingResult? {
        // For empty bottle, calculate how much of each gas to add
        let targetHePartial = (targetPressure * targetMix.helium) / 100.0
        let targetO2Partial = (targetPressure * targetMix.oxygen) / 100.0
        let targetN2Partial = (targetPressure * targetMix.nitrogen) / 100.0

        // Validate all partial pressures are finite
        guard validatePressures(targetHePartial, targetO2Partial, targetN2Partial) else { return nil }

        // Add helium first
        let heToAdd = targetHePartial

        // Then calculate nitrogen needed (add as air)
        let airToAdd = targetN2Partial / BlendingConstants.airNitrogenFraction
        let o2FromAir = airToAdd * BlendingConstants.airOxygenFraction

        guard validatePressures(airToAdd, o2FromAir) else { return nil }

        // Check if adding air for nitrogen gives us too much O2
        if o2FromAir > targetO2Partial + 0.01 {
            // If no helium, this is impossible (need pure nitrogen)
            // If there's helium, we might be able to make it work by using helium as diluent
            if targetHePartial < 0.01 {
                return nil // Impossible - need pure nitrogen, no helium to dilute
            }

            // With helium, we can dilute below 21% O2
            // But we still can't add more O2 than needed, so this blend is still impossible
            return nil
        }

        // Finally add pure oxygen to reach target
        let o2ToAdd = max(0, targetO2Partial - o2FromAir)

        // Validate the final pressure
        let finalPressure = heToAdd + airToAdd + o2ToAdd

        guard validatePressures(finalPressure, heToAdd, o2ToAdd, airToAdd) else { return nil }
        guard finalPressure > 0 else { return nil }

        // Validate component sum matches target
        guard abs(finalPressure - targetPressure) <= 0.1 else { return nil }

        // Calculate volumes
        let heVolume = heToAdd * tankVolume
        let o2Volume = o2ToAdd * tankVolume

        guard validatePressures(heVolume, o2Volume) else { return nil }

        // Calculate intermediate pressures
        let pressureAfterHe = heToAdd
        let pressureAfterAir = pressureAfterHe + airToAdd
        let pressureAfterO2 = pressureAfterAir + o2ToAdd

        return BlendingResult(
            heliumToAdd: heToAdd,
            oxygenToAdd: o2ToAdd,
            airToAdd: airToAdd,
            oxygenVolume: o2Volume,
            heliumVolume: heVolume,
            pressureAfterHelium: pressureAfterHe,
            pressureAfterAir: pressureAfterAir,
            pressureAfterOxygen: pressureAfterO2,
            airToRelease: 0,
            pressureAfterRelease: 0,
            finalMix: targetMix
        )
    }

    /// Calculate blending requirements using partial pressure method
    ///
    /// Public API maintains 6 parameters for backward compatibility with existing tests.
    /// Internally delegates to `calculateBlendInternal` with grouped parameters.
    ///
    /// - Parameters:
    ///   - currentMix: Current gas mix in cylinder
    ///   - currentPressure: Current pressure in cylinder (bar)
    ///   - targetMix: Desired final gas mix
    ///   - targetPressure: Desired final pressure (bar)
    ///   - topupMix: Gas used to top up (typically air)
    ///   - tankVolume: Tank volume in liters
    /// - Returns: BlendingResult with all calculation details
    static func calculateBlend(
        currentMix: GasMix,
        currentPressure: Double,
        targetMix: GasMix,
        targetPressure: Double,
        topupMix: GasMix,
        tankVolume: Double
    ) -> BlendingResult? {
        let input = BlendingInput(
            currentMix: currentMix,
            currentPressure: currentPressure,
            targetMix: targetMix,
            targetPressure: targetPressure,
            topupMix: topupMix,
            tankVolume: tankVolume
        )
        return calculateBlendInternal(input)
    }

    /// Build the final blending result
    private static func buildBlendingResult(_ components: BlendingResultComponents) -> BlendingResult? {
        guard validatePressures(
            components.heToAdd,
            components.actualO2ToAdd,
            components.actualAirToAdd,
            components.heVolume,
            components.o2Volume,
            components.pressureAfterHe,
            components.finalPressure
        ) else { return nil }
        guard components.finalPressure > 0 else { return nil }

        let pressureAfterAirActual = components.pressureAfterHe + components.actualAirToAdd

        return BlendingResult(
            heliumToAdd: components.heToAdd,
            oxygenToAdd: components.actualO2ToAdd,
            airToAdd: components.actualAirToAdd,
            oxygenVolume: components.o2Volume,
            heliumVolume: components.heVolume,
            pressureAfterHelium: components.pressureAfterHe,
            pressureAfterAir: pressureAfterAirActual,
            pressureAfterOxygen: components.finalPressure,
            airToRelease: components.airToRelease,
            pressureAfterRelease: components.pressureAfterRelease,
            finalMix: components.finalMix
        )
    }

    // Internal calculation with reduced parameters
    private static func calculateBlendInternal(_ input: BlendingInput) -> BlendingResult? {
        guard input.isValid else { return nil }

        // Special case: empty bottle (effectively 0 bar)
        if abs(input.currentPressure) < BlendingConstants.epsilon {
            return calculateEmptyBottleBlend(
                targetMix: input.targetMix,
                targetPressure: input.targetPressure,
                tankVolume: input.tankVolume
            )
        }

        // Calculate using partial pressure method
        // Order: Helium → Oxygen → Air
        // 1. Calculate Helium needed
        let currentHePartial = (input.currentPressure * input.currentMix.helium) / 100.0
        let targetHePartial = (input.targetPressure * input.targetMix.helium) / 100.0
        guard currentHePartial.isFinite && targetHePartial.isFinite else { return nil }
        let heToAdd = max(0, targetHePartial - currentHePartial)

        // Check if oxygen needs to be removed (impossible in blending)
        let targetO2Partial = (input.targetPressure * input.targetMix.oxygen) / 100.0
        let currentO2Partial = (input.currentPressure * input.currentMix.oxygen) / 100.0
        guard targetO2Partial.isFinite && currentO2Partial.isFinite else { return nil }

        var airToRelease = 0.0
        var pressureAfterRelease = input.currentPressure
        var startingPressure = input.currentPressure
        var startingO2Partial = currentO2Partial

        // Calculate initial O2 and N2 needed
        let targetN2Partial = (input.targetPressure * input.targetMix.nitrogen) / 100.0
        let currentN2Partial = (input.currentPressure * input.currentMix.nitrogen) / 100.0
        guard targetN2Partial.isFinite && currentN2Partial.isFinite else { return nil }

        let n2ToAdd = targetN2Partial - currentN2Partial

        // Check if we need to reduce nitrogen (and thus release air)
        if n2ToAdd < -0.01 {
            // Need to release air to reduce nitrogen
            // Calculate what pressure gives us the target nitrogen partial pressure
            let pressureForTargetN2 = (targetN2Partial * 100.0) / input.currentMix.nitrogen
            guard pressureForTargetN2.isFinite && pressureForTargetN2 > 0 else { return nil }

            // Make sure we're not trying to increase pressure while removing nitrogen
            guard pressureForTargetN2 <= input.currentPressure else { return nil }

            airToRelease = input.currentPressure - pressureForTargetN2
            pressureAfterRelease = pressureForTargetN2
            startingPressure = pressureForTargetN2
            startingO2Partial = (pressureForTargetN2 * input.currentMix.oxygen) / 100.0

            // After releasing air, we should only need to add pure oxygen to reach target pressure
            // Verify that adding pure O2 will give us the correct final O2 percentage
            let o2AfterRelease = startingO2Partial
            let o2ToAdd = targetO2Partial - o2AfterRelease
            guard o2ToAdd >= -0.01 else { return nil } // Can't remove oxygen

            let actualO2ToAdd = max(0, o2ToAdd)
            let actualAirToAdd = 0.0 // No air needed since we already have correct N2

            // Verify final pressure will be correct
            let calculatedFinalPressure = pressureForTargetN2 + actualO2ToAdd
            guard abs(calculatedFinalPressure - input.targetPressure) < 0.2 else { return nil }

            // Pressure after adding helium (none in this case)
            let pressureAfterHe = startingPressure + heToAdd

            // Final pressure after adding oxygen
            let finalPressure = pressureAfterHe + actualO2ToAdd

            // Validate final pressure
            guard abs(finalPressure - input.targetPressure) < 0.2 else { return nil }

            // Calculate volumes
            let o2Volume = actualO2ToAdd * input.tankVolume
            let heVolume = heToAdd * input.tankVolume

            // Calculate final mix percentage
            let finalMix = GasMix(
                oxygen: (targetO2Partial / input.targetPressure) * 100.0,
                nitrogen: (targetN2Partial / input.targetPressure) * 100.0,
                helium: (targetHePartial / input.targetPressure) * 100.0
            )

            // Build and validate result
            let components = BlendingResultComponents(
                heToAdd: heToAdd,
                actualO2ToAdd: actualO2ToAdd,
                actualAirToAdd: actualAirToAdd,
                heVolume: heVolume,
                o2Volume: o2Volume,
                pressureAfterHe: pressureAfterHe,
                finalPressure: finalPressure,
                airToRelease: airToRelease,
                pressureAfterRelease: pressureAfterRelease,
                finalMix: finalMix
            )

            guard let result = buildBlendingResult(components) else { return nil }
            return result.isValid ? result : nil
        }

        // Normal case: adding nitrogen (as air)
        let airToAdd = n2ToAdd / BlendingConstants.airNitrogenFraction
        guard airToAdd.isFinite else { return nil }

        let o2FromAir = airToAdd * BlendingConstants.airOxygenFraction
        let o2Needed = targetO2Partial - currentO2Partial - o2FromAir
        guard o2Needed.isFinite else { return nil }

        // Check if we need to release air (for oxygen reduction while adding nitrogen)
        if o2Needed < -0.01 {
            if let optimalPressure = findOptimalPressureForO2Reduction(
                currentPressure: input.currentPressure,
                currentMix: input.currentMix,
                targetO2Partial: targetO2Partial,
                targetN2Partial: targetN2Partial
            ), optimalPressure < input.currentPressure {
                airToRelease = input.currentPressure - optimalPressure
                pressureAfterRelease = optimalPressure
                startingPressure = optimalPressure
                startingO2Partial = (optimalPressure * input.currentMix.oxygen) / 100.0
            } else if let optimalPressure = findOptimalPressureForO2Reduction(
                currentPressure: input.currentPressure,
                currentMix: input.currentMix,
                targetO2Partial: targetO2Partial,
                targetN2Partial: targetN2Partial
            ), optimalPressure >= input.currentPressure {
                // Already possible at current pressure - no air release needed
            } else {
                // Even at the lowest possible pressure, blend isn't possible
                return nil
            }
        }

        // Calculate actual air and oxygen amounts considering constraints
        guard let gasAmounts = calculateFinalGasAmounts(
            startingPressure: startingPressure,
            startingO2Partial: startingO2Partial,
            currentMix: input.currentMix,
            targetO2Partial: targetO2Partial,
            targetN2Partial: targetN2Partial
        ) else { return nil }

        let actualAirToAdd = gasAmounts.airToAdd
        let actualO2ToAdd = gasAmounts.o2ToAdd

        // Pressure after adding helium
        let pressureAfterHe = startingPressure + heToAdd

        // Final pressure after adding air and oxygen
        let finalPressure = pressureAfterHe + actualAirToAdd + actualO2ToAdd

        // Validate final pressure
        guard abs(finalPressure - input.targetPressure) < 0.2 else { return nil }

        // Calculate volumes
        let o2Volume = actualO2ToAdd * input.tankVolume
        let heVolume = heToAdd * input.tankVolume

        // Calculate final mix percentage
        let finalMix = GasMix(
            oxygen: (targetO2Partial / input.targetPressure) * 100.0,
            nitrogen: (targetN2Partial / input.targetPressure) * 100.0,
            helium: (targetHePartial / input.targetPressure) * 100.0
        )

        // Build and validate result
        let components = BlendingResultComponents(
            heToAdd: heToAdd,
            actualO2ToAdd: actualO2ToAdd,
            actualAirToAdd: actualAirToAdd,
            heVolume: heVolume,
            o2Volume: o2Volume,
            pressureAfterHe: pressureAfterHe,
            finalPressure: finalPressure,
            airToRelease: airToRelease,
            pressureAfterRelease: pressureAfterRelease,
            finalMix: finalMix
        )

        guard let result = buildBlendingResult(components) else { return nil }
        return result.isValid ? result : nil
    }
}
