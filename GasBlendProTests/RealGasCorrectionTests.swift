import Testing
@testable import GasBlendPro

@Suite("Real Gas Correction Tests")
struct RealGasCorrectionTests {
    private let tolerance = 0.001

    // MARK: - Compressibility Factor Tests

    @Test("Oxygen Z-factor at ambient pressure is 1.0")
    func testOxygenAtAmbient() {
        let z = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 1.0)
        #expect(abs(z - 1.0) < tolerance)
    }

    @Test("Oxygen Z-factor decreases with pressure")
    func testOxygenDecreasesWithPressure() {
        let z100 = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 100)
        let z200 = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 200)
        let z300 = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 300)

        #expect(z100 > z200)
        #expect(z200 > z300)
        #expect(z300 < 1.0)
    }

    @Test("Oxygen Z-factor at 200 bar is approximately 0.978")
    func testOxygenAt200Bar() {
        let z = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 200)
        #expect(abs(z - 0.978) < 0.005)
    }

    @Test("Oxygen Z-factor at 300 bar is approximately 0.955")
    func testOxygenAt300Bar() {
        let z = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 300)
        #expect(abs(z - 0.955) < 0.005)
    }

    @Test("Helium Z-factor at ambient pressure is 1.0")
    func testHeliumAtAmbient() {
        let z = RealGasCorrection.compressibilityFactor(for: .helium, at: 1.0)
        #expect(abs(z - 1.0) < tolerance)
    }

    @Test("Helium Z-factor increases slightly with pressure")
    func testHeliumIncreasesWithPressure() {
        let z100 = RealGasCorrection.compressibilityFactor(for: .helium, at: 100)
        let z200 = RealGasCorrection.compressibilityFactor(for: .helium, at: 200)
        let z300 = RealGasCorrection.compressibilityFactor(for: .helium, at: 300)

        #expect(z100 < z200)
        #expect(z200 < z300)
        #expect(z300 > 1.0)
    }

    @Test("Helium Z-factor at 200 bar is approximately 1.012")
    func testHeliumAt200Bar() {
        let z = RealGasCorrection.compressibilityFactor(for: .helium, at: 200)
        #expect(abs(z - 1.012) < 0.005)
    }

    // MARK: - Interpolation Tests

    @Test("Z-factor interpolates correctly between data points")
    func testInterpolation() {
        // Between 200 bar (0.978) and 250 bar (0.968)
        let z225 = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 225)

        // Should be halfway between: (0.978 + 0.968) / 2 = 0.973
        #expect(abs(z225 - 0.973) < 0.005)
    }

    @Test("Z-factor at exact table value matches")
    func testExactTableValue() {
        let z200 = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 200)
        #expect(abs(z200 - 0.978) < tolerance)
    }

    @Test("Z-factor below minimum pressure returns minimum value")
    func testBelowMinimum() {
        let z = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 0.5)
        #expect(abs(z - 1.0) < tolerance)
    }

    @Test("Z-factor above maximum pressure returns maximum value")
    func testAboveMaximum() {
        let z = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 500)
        let maxZ = 0.922 // Maximum O₂ Z-factor in table
        #expect(abs(z - maxZ) < 0.01)
    }

    // MARK: - Real Volume Calculation Tests

    @Test("Real volume equals ideal at low pressure")
    func testRealVolumeAtLowPressure() {
        let idealVolume = 1000.0 // liters
        let realVolume = RealGasCorrection.realVolume(
            fromIdeal: idealVolume,
            gasType: .oxygen,
            pressure: 1.0
        )
        #expect(abs(realVolume - idealVolume) < 1.0)
    }

    @Test("Real O₂ volume is higher than ideal at high pressure")
    func testRealOxygenVolumeAtHighPressure() {
        let idealVolume = 2304.0 // liters (96 bar × 24L)
        let realVolume = RealGasCorrection.realVolume(
            fromIdeal: idealVolume,
            gasType: .oxygen,
            pressure: 300.0
        )

        // At 300 bar, Z ≈ 0.955, so real = ideal / 0.955 ≈ 2413 L
        #expect(realVolume > idealVolume)
        #expect(abs(realVolume - 2413) < 50) // Within 50L
    }

    @Test("Real He volume is lower than ideal at high pressure")
    func testRealHeliumVolumeAtHighPressure() {
        let idealVolume = 1000.0 // liters
        let realVolume = RealGasCorrection.realVolume(
            fromIdeal: idealVolume,
            gasType: .helium,
            pressure: 300.0
        )

        // At 300 bar, Z ≈ 1.018, so real = ideal / 1.018 ≈ 982 L
        #expect(realVolume < idealVolume)
        #expect(abs(realVolume - 982) < 10)
    }

    // MARK: - Pressure Deduction Tests

    @Test("User's real-world blend - O₂ at 274 bar")
    func testUserBlendScenario() {
        // User's blend: 24L tank, 104→200 bar, needs 2304L O₂
        let volumeNeeded = 2304.0 // 96 bar × 24L
        let storageTankVolume = 50.0 // L
        let storageTankPressure = 274.0 // bar (starting pressure)

        let deduction = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: storageTankPressure,
            gasType: .oxygen
        )

        // User reported: ideal was 46.08 bar, real was 50.08 bar (4 bar more)
        // At 274 bar, Z ≈ 0.96, so deduction should be ~48 bar
        #expect(deduction > 46.08) // More than ideal
        #expect(abs(deduction - 50.0) < 3.0) // Within 3 bar of user's measurement
    }

    @Test("Ideal gas pressure deduction at low pressure")
    func testIdealGasPressureDeduction() {
        let volumeNeeded = 1000.0 // liters
        let storageTankVolume = 50.0 // L
        let storageTankPressure = 50.0 // bar (low pressure)

        let deduction = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: storageTankPressure,
            gasType: .oxygen
        )

        // At low pressure, should be close to ideal: 1000 / 50 = 20 bar
        #expect(abs(deduction - 20.0) < 0.5)
    }

    @Test("O₂ storage tank deduction increases with pressure")
    func testOxygenDeductionIncreasesWithPressure() {
        let volumeNeeded = 2000.0 // liters
        let storageTankVolume = 50.0 // L

        let deduction100 = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: 100,
            gasType: .oxygen
        )

        let deduction300 = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: 300,
            gasType: .oxygen
        )

        // Higher pressure = more gas needed = larger deduction
        #expect(deduction300 > deduction100)
    }

    @Test("He storage tank deduction decreases with pressure")
    func testHeliumDeductionDecreasesWithPressure() {
        let volumeNeeded = 2000.0 // liters
        let storageTankVolume = 50.0 // L

        let deduction100 = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: 100,
            gasType: .helium
        )

        let deduction300 = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: 300,
            gasType: .helium
        )

        // Higher pressure He = less gas needed = smaller deduction
        #expect(deduction300 < deduction100)
    }

    // MARK: - Correction Percentage Tests

    @Test("O₂ correction percentage at 200 bar is ~2%")
    func testOxygenCorrectionAt200Bar() {
        let correction = RealGasCorrection.correctionPercentage(for: .oxygen, at: 200)

        // Z ≈ 0.978, so correction ≈ (1/0.978 - 1) × 100 ≈ 2.2%
        #expect(abs(correction - 2.2) < 0.5)
    }

    @Test("O₂ correction percentage at 300 bar is ~5%")
    func testOxygenCorrectionAt300Bar() {
        let correction = RealGasCorrection.correctionPercentage(for: .oxygen, at: 300)

        // Z ≈ 0.955, so correction ≈ (1/0.955 - 1) × 100 ≈ 4.7%
        #expect(abs(correction - 4.7) < 0.5)
    }

    @Test("He correction percentage at 300 bar is ~-1.8%")
    func testHeliumCorrectionAt300Bar() {
        let correction = RealGasCorrection.correctionPercentage(for: .helium, at: 300)

        // Z ≈ 1.018, so correction ≈ (1/1.018 - 1) × 100 ≈ -1.8%
        #expect(correction < 0) // Negative means less gas needed
        #expect(abs(correction - (-1.8)) < 0.5)
    }

    @Test("Correction percentage is near zero at low pressure")
    func testCorrectionNearZeroAtLowPressure() {
        let correction = RealGasCorrection.correctionPercentage(for: .oxygen, at: 1.0)
        #expect(abs(correction) < 0.1)
    }

    // MARK: - Gas Behavior Info Tests

    @Test("Gas behavior info provides correct description at low pressure")
    func testGasBehaviorInfoLowPressure() {
        let info = RealGasCorrection.gasBehaviorInfo(for: .oxygen, at: 50)

        #expect(abs(info.deviation) < 1.0)
        #expect(info.description.contains("Near ideal"))
    }

    @Test("Gas behavior info provides correct description at high pressure")
    func testGasBehaviorInfoHighPressure() {
        let info = RealGasCorrection.gasBehaviorInfo(for: .oxygen, at: 300)

        #expect(info.deviation > 1.0)
        #expect(info.description.contains("more gas needed"))
    }

    @Test("Helium gas behavior info shows less gas needed")
    func testHeliumGasBehaviorInfo() {
        let info = RealGasCorrection.gasBehaviorInfo(for: .helium, at: 300)

        #expect(info.deviation < 0)
        #expect(info.description.contains("less gas needed"))
    }

    // MARK: - Edge Cases

    @Test("Zero pressure returns ideal gas")
    func testZeroPressure() {
        let z = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 0)
        #expect(abs(z - 1.0) < tolerance)
    }

    @Test("Negative pressure returns ideal gas")
    func testNegativePressure() {
        let z = RealGasCorrection.compressibilityFactor(for: .oxygen, at: -10)
        #expect(abs(z - 1.0) < tolerance)
    }

    @Test("Very high pressure is clamped to maximum")
    func testVeryHighPressure() {
        let z1000 = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 1000)
        let z400 = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 400)
        #expect(abs(z1000 - z400) < tolerance)
    }

    @Test("Zero volume returns zero deduction")
    func testZeroVolume() {
        let deduction = RealGasCorrection.pressureDeduction(
            volumeNeeded: 0,
            storageTankVolume: 50,
            storageTankPressure: 300,
            gasType: .oxygen
        )
        #expect(abs(deduction) < tolerance)
    }

    // MARK: - Temperature Correction Tests

    @Test("Temperature correction - O₂ at 10°C needs more gas")
    func testOxygenColdTemperature() {
        let z20C = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 274, temperature: 20)
        let z10C = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 274, temperature: 10)

        // At 10°C (colder), Z should be lower than at 20°C
        #expect(z10C < z20C)

        // Temperature diff: -10°C, correction: 0.1% per °C = -1% total
        // So z10C should be ~1% less than z20C
        let expectedDiff = z20C * 0.01 // 1% difference
        #expect(abs((z20C - z10C) - expectedDiff) < 0.001)
    }

    @Test("Temperature correction - O₂ at 30°C needs less gas")
    func testOxygenWarmTemperature() {
        let z20C = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 274, temperature: 20)
        let z30C = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 274, temperature: 30)

        // At 30°C (warmer), Z should be higher than at 20°C
        #expect(z30C > z20C)

        // Temperature diff: +10°C, correction: 0.1% per °C = +1% total
        let expectedDiff = z20C * 0.01
        #expect(abs((z30C - z20C) - expectedDiff) < 0.001)
    }

    @Test("Temperature correction - He at 10°C")
    func testHeliumColdTemperature() {
        let z20C = RealGasCorrection.compressibilityFactor(for: .helium, at: 300, temperature: 20)
        let z10C = RealGasCorrection.compressibilityFactor(for: .helium, at: 300, temperature: 10)

        // Helium has smaller temperature correction (0.05% per °C vs 0.1% for O₂)
        #expect(z10C < z20C)

        // Temperature diff: -10°C, correction: 0.05% per °C = -0.5% total
        let expectedDiff = z20C * 0.005
        #expect(abs((z20C - z10C) - expectedDiff) < 0.001)
    }

    @Test("Temperature correction - real volume increases at cold temps")
    func testRealVolumeAtColdTemperature() {
        let idealVolume = 2304.0
        let pressure = 274.0

        let volume20C = RealGasCorrection.realVolume(
            fromIdeal: idealVolume,
            gasType: .oxygen,
            pressure: pressure,
            temperature: 20
        )

        let volume10C = RealGasCorrection.realVolume(
            fromIdeal: idealVolume,
            gasType: .oxygen,
            pressure: pressure,
            temperature: 10
        )

        // At colder temperature, need MORE real volume (Z is lower)
        #expect(volume10C > volume20C)
    }

    @Test("Temperature correction - user's scenario at 10°C")
    func testUserScenarioAt10C() {
        // User's blend at potentially 10°C ambient
        let volumeNeeded = 2304.0
        let storageTankVolume = 50.0
        let storageTankPressure = 274.0

        let deduction = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: storageTankPressure,
            gasType: .oxygen,
            temperature: 10.0
        )

        // At 10°C, should be closer to user's observation of ~50 bar
        // Expected: ~48.4 bar deduction
        #expect(deduction > 48.0)
        #expect(deduction < 49.0)

        let endingPressure = storageTankPressure - deduction
        // Should end around 225.6 bar
        #expect(abs(endingPressure - 225.6) < 1.0)
    }

    @Test("Temperature correction - pressure deduction increases with cold")
    func testPressureDeductionWithTemperature() {
        let volumeNeeded = 2000.0
        let storageTankVolume = 50.0
        let storageTankPressure = 300.0

        let deduction10C = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: storageTankPressure,
            gasType: .oxygen,
            temperature: 10
        )

        let deduction20C = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: storageTankPressure,
            gasType: .oxygen,
            temperature: 20
        )

        let deduction30C = RealGasCorrection.pressureDeduction(
            volumeNeeded: volumeNeeded,
            storageTankVolume: storageTankVolume,
            storageTankPressure: storageTankPressure,
            gasType: .oxygen,
            temperature: 30
        )

        // Colder = more deduction, warmer = less deduction
        #expect(deduction10C > deduction20C)
        #expect(deduction20C > deduction30C)
    }

    @Test("Temperature correction - correction percentage changes with temp")
    func testCorrectionPercentageWithTemperature() {
        let correction10C = RealGasCorrection.correctionPercentage(
            for: .oxygen,
            at: 300,
            temperature: 10
        )

        let correction20C = RealGasCorrection.correctionPercentage(
            for: .oxygen,
            at: 300,
            temperature: 20
        )

        let correction30C = RealGasCorrection.correctionPercentage(
            for: .oxygen,
            at: 300,
            temperature: 30
        )

        // Colder = higher correction % (need more gas)
        #expect(correction10C > correction20C)
        #expect(correction20C > correction30C)
    }

    @Test("Temperature at 20°C should match default")
    func testDefaultTemperatureMatches() {
        // Explicit 20°C should give same result as default (no temperature param)
        let zDefault = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 200)
        let z20C = RealGasCorrection.compressibilityFactor(for: .oxygen, at: 200, temperature: 20)

        #expect(abs(zDefault - z20C) < tolerance)
    }
}
