import Testing
@testable import GasBlendPro

/// Comprehensive unit tests for gas blending calculations
/// These tests ensure safety-critical calculations remain correct during refactoring
@Suite("Blending Calculation Tests")
struct BlendingCalculationTests {
    // MARK: - Test Constants

    private let standardTankVolume = 12.0 // liters
    private let tolerance = 0.1 // bar tolerance for floating-point comparisons

    // MARK: - Helper Functions

    /// Validates that a blending result is physically valid
    private func validateBlendingResult(_ result: BlendingResult?) {
        #expect(result != nil, "Result should not be nil")
        guard let result = result else { return }

        // All pressures must be non-negative
        #expect(result.heliumToAdd >= 0, "Helium to add must be non-negative")
        #expect(result.oxygenToAdd >= 0, "Oxygen to add must be non-negative")
        #expect(result.airToAdd >= 0, "Air to add must be non-negative")

        // Volumes must be non-negative and finite
        #expect(result.oxygenVolume >= 0 && result.oxygenVolume.isFinite)
        #expect(result.heliumVolume >= 0 && result.heliumVolume.isFinite)

        // Final mix should be valid
        #expect(result.finalMix.isValid, "Final mix must be valid")

        // Result should report as valid
        #expect(result.isValid, "Result isValid should be true")
    }

    /// Asserts that two gas mixes are approximately equal
    private func assertMixesEqual(
        _ actual: GasMix,
        _ expected: GasMix,
        tolerance: Double = 0.5
    ) {
        #expect(
            abs(actual.oxygen - expected.oxygen) < tolerance,
            "Oxygen mismatch: got \(actual.oxygen), expected \(expected.oxygen)"
        )
        #expect(
            abs(actual.nitrogen - expected.nitrogen) < tolerance,
            "Nitrogen mismatch: got \(actual.nitrogen), expected \(expected.nitrogen)"
        )
        #expect(
            abs(actual.helium - expected.helium) < tolerance,
            "Helium mismatch: got \(actual.helium), expected \(expected.helium)"
        )
    }

    // MARK: - Empty Tank Tests

    @Test("Empty tank to Air")
    func testEmptyTankToAir() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Empty tank to air should just add air
        #expect(result.heliumToAdd < tolerance)
        #expect(result.oxygenToAdd < tolerance)
        #expect(abs(result.airToAdd - 200) < tolerance)
        assertMixesEqual(result.finalMix, GasMix(oxygen: 21, nitrogen: 79, helium: 0))
    }

    @Test("Empty tank to EAN32")
    func testEmptyTankToEAN32() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Should add air for nitrogen, then pure O2 to reach 32%
        #expect(result.heliumToAdd < tolerance)
        #expect(result.oxygenToAdd > 0, "Should add pure oxygen")
        #expect(result.airToAdd > 0, "Should add air for nitrogen")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 32, nitrogen: 68, helium: 0))
    }

    @Test("Empty tank to Trimix 21/35")
    func testEmptyTankToTrimix21_35() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 21, nitrogen: 44, helium: 35),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Should add helium first, then air
        #expect(result.heliumToAdd > 50, "Should add significant helium")
        #expect(result.airToAdd > 0, "Should add air")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 21, nitrogen: 44, helium: 35), tolerance: 1.0)
    }

    @Test("Empty tank to Trimix 18/45")
    func testEmptyTankToTrimix18_45() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 18, nitrogen: 37, helium: 45),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Hypoxic mix - should add lots of helium
        #expect(result.heliumToAdd > 70, "Should add significant helium for 45%")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 18, nitrogen: 37, helium: 45), tolerance: 1.0)
    }

    // MARK: - Partial Tank Tests

    @Test("Air to EAN32 from 100 bar")
    func testAirToEAN32From100Bar() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 100,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Starting with air, enriching to EAN32
        #expect(result.oxygenToAdd > 0, "Should add oxygen")
        #expect(result.airToAdd > 0, "Should add air")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 32, nitrogen: 68, helium: 0))
    }

    @Test("EAN32 to EAN36 from 150 bar")
    func testEAN32ToEAN36From150Bar() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            currentPressure: 150,
            targetMix: GasMix(oxygen: 36, nitrogen: 64, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Enriching from EAN32 to EAN36
        #expect(result.oxygenToAdd > 0, "Should add oxygen")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 36, nitrogen: 64, helium: 0))
    }

    @Test("Air to Trimix 21/35 from 50 bar")
    func testAirToTrimix21_35From50Bar() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 50,
            targetMix: GasMix(oxygen: 21, nitrogen: 44, helium: 35),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Adding helium to air
        #expect(result.heliumToAdd > 0, "Should add helium")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 21, nitrogen: 44, helium: 35), tolerance: 1.0)
    }

    // MARK: - Oxygen Reduction Tests (Air Release Required)

    @Test("EAN50 down to EAN32")
    func testEAN50ToEAN32() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 50, nitrogen: 50, helium: 0),
            currentPressure: 100,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Should release air to reduce O2 percentage
        #expect(result.airToRelease > 0, "Should release air to reduce oxygen")
        #expect(result.pressureAfterRelease < 100, "Pressure after release should be lower")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 32, nitrogen: 68, helium: 0))
    }

    @Test("Reducing O2 while increasing pressure is not supported")
    func testReduceOxygenWhileIncreasingPressure() {
        // KNOWN LIMITATION: The current implementation cannot reduce oxygen percentage
        // while simultaneously increasing pressure, even with air release.
        // This is a physics/algorithm limitation - you'd need to vent to atmosphere
        // and then fill fresh, which this calculator doesn't support.

        // Test case 1: EAN36 @ 150 bar → Air @ 200 bar
        let result1 = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 36, nitrogen: 64, helium: 0),
            currentPressure: 150,
            targetMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )
        #expect(result1 == nil, "Cannot reduce O2 from 36% to 21% while increasing pressure")

        // Test case 2: Even with lower starting pressure
        let result2 = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 36, nitrogen: 64, helium: 0),
            currentPressure: 50,
            targetMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )
        #expect(result2 == nil, "Still cannot reduce O2 percentage when target pressure > current")
    }

    // MARK: - Impossible Blend Tests

    @Test("Cannot reduce helium")
    func testCannotReduceHelium() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 44, helium: 35),
            currentPressure: 100,
            targetMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        // Should return nil - cannot remove helium
        #expect(result == nil, "Cannot reduce helium percentage - should return nil")
    }

    @Test("Target pressure less than current")
    func testTargetPressureLessThanCurrent() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 200,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 100,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        // Should return nil - cannot reduce pressure
        #expect(result == nil, "Target pressure less than current - should return nil")
    }

    @Test("Invalid current mix")
    func testInvalidCurrentMix() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 60, nitrogen: 60, helium: 0), // Totals 120%!
            currentPressure: 100,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        #expect(result == nil, "Invalid current mix should return nil")
    }

    @Test("Invalid target mix")
    func testInvalidTargetMix() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 100,
            targetMix: GasMix(oxygen: 60, nitrogen: 60, helium: 0), // Totals 120%!
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        #expect(result == nil, "Invalid target mix should return nil")
    }

    // MARK: - Edge Cases

    @Test("Zero tank volume")
    func testZeroTankVolume() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 100,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: 0
        )

        #expect(result == nil, "Zero tank volume should return nil")
    }

    @Test("Negative current pressure")
    func testNegativeCurrentPressure() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: -10,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        #expect(result == nil, "Negative current pressure should return nil")
    }

    @Test("Excessive target pressure")
    func testExcessiveTargetPressure() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 100,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 500, // Exceeds 400 bar limit
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        #expect(result == nil, "Excessive target pressure should return nil")
    }

    @Test("Same pressure and mix")
    func testSamePressureAndMix() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            currentPressure: 200,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Should add nothing
        #expect(result.heliumToAdd < tolerance)
        #expect(result.oxygenToAdd < tolerance)
        #expect(result.airToAdd < tolerance)
    }

    // MARK: - Real-World Dive Scenarios

    @Test("Technical dive: Air to Trimix 18/45 (deep dive)")
    func testTechnicalDiveDeepTrimix() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 30,
            targetMix: GasMix(oxygen: 18, nitrogen: 37, helium: 45),
            targetPressure: 232, // Double 85 cuft tank
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: 11.1
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Deep technical diving mix
        #expect(result.heliumVolume > 0, "Should use helium")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 18, nitrogen: 37, helium: 45), tolerance: 1.5)
    }

    @Test("Recreational dive: Air to EAN32 (standard nitrox)")
    func testRecreationalDiveEAN32() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 50,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: 12.0
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Common recreational nitrox
        assertMixesEqual(result.finalMix, GasMix(oxygen: 32, nitrogen: 68, helium: 0))
    }

    @Test("Deco gas: Air to EAN50")
    func testDecoGasEAN50() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 50, nitrogen: 50, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: 7.0 // Smaller deco cylinder
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Rich nitrox for decompression
        // EAN50 needs more air than pure O2 because air provides the nitrogen
        #expect(result.airToAdd > result.oxygenToAdd, "EAN50 needs more air than pure O2")
        #expect(result.oxygenToAdd > 0, "Still needs some pure O2")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 50, nitrogen: 50, helium: 0))
    }

    @Test("Travel gas: Air to EAN36")
    func testTravelGasEAN36() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 36, nitrogen: 64, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: 11.1
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        assertMixesEqual(result.finalMix, GasMix(oxygen: 36, nitrogen: 64, helium: 0))
    }

    // MARK: - Volume Calculation Tests

    @Test("Volume calculations are correct")
    func testVolumeCalculations() {
        let tankVolume = 12.0
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: tankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Volume = Pressure × TankVolume
        let expectedO2Volume = result.oxygenToAdd * tankVolume
        #expect(abs(result.oxygenVolume - expectedO2Volume) < 0.1, "Oxygen volume should be pressure × tank volume")

        let expectedHeVolume = result.heliumToAdd * tankVolume
        #expect(abs(result.heliumVolume - expectedHeVolume) < 0.1, "Helium volume should be pressure × tank volume")
    }

    // MARK: - Numerical Stability Tests

    @Test("Very small pressure differences")
    func testSmallPressureDifferences() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            currentPressure: 199.5,
            targetMix: GasMix(oxygen: 32, nitrogen: 68, helium: 0),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Should handle small differences gracefully
        #expect(result.airToAdd < 1, "Small pressure difference should add minimal air")
    }

    @Test("Very small oxygen percentage")
    func testSmallOxygenPercentage() {
        let result = BlendingCalculator.calculateBlend(
            currentMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            currentPressure: 0,
            targetMix: GasMix(oxygen: 10, nitrogen: 20, helium: 70),
            targetPressure: 200,
            topupMix: GasMix(oxygen: 21, nitrogen: 79, helium: 0),
            tankVolume: standardTankVolume
        )

        validateBlendingResult(result)
        guard let result = result else { return }

        // Hypoxic trimix - should have very high helium
        #expect(result.heliumToAdd > 100, "10% O2 mix needs lots of helium")
        assertMixesEqual(result.finalMix, GasMix(oxygen: 10, nitrogen: 20, helium: 70), tolerance: 1.5)
    }
}
