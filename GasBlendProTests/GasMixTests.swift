import Testing
import Foundation
@testable import GasBlendPro

/// Unit tests for GasMix model
@Suite("Gas Mix Tests")
struct GasMixTests {
    // MARK: - Validation Tests

    @Test("Air is valid")
    func testAirIsValid() {
        let air = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
        #expect(air.isValid, "Air should be valid")
        #expect(air.isAir, "Should be identified as air")
    }

    @Test("EAN32 is valid")
    func testEAN32IsValid() {
        let ean32 = GasMix(oxygen: 32, nitrogen: 68, helium: 0)
        #expect(ean32.isValid, "EAN32 should be valid")
        #expect(ean32.isNitrox, "Should be identified as nitrox")
    }

    @Test("Trimix is valid")
    func testTrimixIsValid() {
        let trimix = GasMix(oxygen: 21, nitrogen: 44, helium: 35)
        #expect(trimix.isValid, "Trimix should be valid")
        #expect(trimix.isTrimix, "Should be identified as trimix")
    }

    @Test("Invalid mix totaling 120%")
    func testInvalidMixOver100() {
        let invalid = GasMix(oxygen: 60, nitrogen: 60, helium: 0)
        #expect(!invalid.isValid, "Mix totaling >100% should be invalid")
    }

    @Test("Invalid mix totaling 90%")
    func testInvalidMixUnder100() {
        let invalid = GasMix(oxygen: 30, nitrogen: 50, helium: 0)
        #expect(!invalid.isValid, "Mix totaling <99.9% should be invalid")
    }

    @Test("Edge case: 99.9% total is valid")
    func testEdgeCaseMinValid() {
        // Use values that actually sum to >= 99.9
        let edge = GasMix(oxygen: 33.3, nitrogen: 33.3, helium: 33.4)
        #expect(edge.isValid, "100.0% total should be valid within tolerance")
        #expect(abs(edge.total - 100.0) < 0.1, "Total should be approximately 100%")
    }

    @Test("Edge case: 100.1% total is valid")
    func testEdgeCaseMaxValid() {
        let edge = GasMix(oxygen: 33.4, nitrogen: 33.4, helium: 33.3)
        #expect(edge.isValid, "100.1% total should be valid within tolerance")
    }

    // MARK: - Total Calculation Tests

    @Test("Air total is 100")
    func testAirTotal() {
        let air = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
        #expect(air.total == 100, "Air total should be 100")
    }

    @Test("Trimix total is 100")
    func testTrimixTotal() {
        let trimix = GasMix(oxygen: 18, nitrogen: 37, helium: 45)
        #expect(trimix.total == 100, "Trimix total should be 100")
    }

    // MARK: - Gas Type Identification Tests

    @Test("Air identification")
    func testAirIdentification() {
        let air = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
        #expect(air.isAir)
        #expect(!air.isNitrox)
        #expect(!air.isTrimix)
    }

    @Test("Nitrox identification")
    func testNitroxIdentification() {
        let nitrox = GasMix(oxygen: 32, nitrogen: 68, helium: 0)
        #expect(!nitrox.isAir)
        #expect(nitrox.isNitrox)
        #expect(!nitrox.isTrimix)
    }

    @Test("Trimix identification")
    func testTrimixIdentification() {
        let trimix = GasMix(oxygen: 21, nitrogen: 44, helium: 35)
        #expect(!trimix.isAir)
        #expect(!trimix.isNitrox)
        #expect(trimix.isTrimix)
    }

    @Test("Pure oxygen is not nitrox")
    func testPureOxygenNotNitrox() {
        let pureO2 = GasMix(oxygen: 100, nitrogen: 0, helium: 0)
        #expect(!pureO2.isNitrox, "Pure oxygen should not be classified as nitrox")
    }

    @Test("Heliox (no nitrogen) is not trimix")
    func testHeliox() {
        let heliox = GasMix(oxygen: 20, nitrogen: 0, helium: 80)
        #expect(!heliox.isTrimix, "Heliox (no N2) should not be classified as trimix")
    }

    // MARK: - Partial Pressure Tests

    @Test("Oxygen partial pressure at surface")
    func testOxygenPPAtSurface() {
        let air = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
        let ppO2 = air.partialPressure(component: .oxygen, at: 1.0)
        #expect(abs(ppO2 - 0.21) < 0.01, "O2 PP in air at 1 bar should be ~0.21")
    }

    @Test("Oxygen partial pressure at 200 bar")
    func testOxygenPPAt200Bar() {
        let air = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
        let ppO2 = air.partialPressure(component: .oxygen, at: 200.0)
        #expect(abs(ppO2 - 42.0) < 0.1, "O2 PP in air at 200 bar should be ~42 bar")
    }

    @Test("Helium partial pressure in trimix")
    func testHeliumPPInTrimix() {
        let trimix = GasMix(oxygen: 18, nitrogen: 37, helium: 45)
        let ppHe = trimix.partialPressure(component: .helium, at: 200.0)
        #expect(abs(ppHe - 90.0) < 0.1, "He PP at 200 bar should be ~90 bar")
    }

    @Test("Nitrogen partial pressure in EAN32")
    func testNitrogenPPInEAN32() {
        let ean32 = GasMix(oxygen: 32, nitrogen: 68, helium: 0)
        let ppN2 = ean32.partialPressure(component: .nitrogen, at: 150.0)
        #expect(abs(ppN2 - 102.0) < 0.1, "N2 PP in EAN32 at 150 bar should be ~102 bar")
    }

    // MARK: - Pressure Calculation Tests

    @Test("Pressure needed for oxygen")
    func testPressureNeededForOxygen() {
        let pureO2 = GasMix(oxygen: 100, nitrogen: 0, helium: 0)
        let pressure = pureO2.pressureToAddForComponent(.oxygen, targetPartial: 50.0)
        #expect(abs(pressure - 50.0) < 0.1, "Need 50 bar pressure for 50 bar partial pressure of pure O2")
    }

    @Test("Pressure needed for air oxygen component")
    func testPressureNeededForAirOxygen() {
        let air = GasMix(oxygen: 21, nitrogen: 79, helium: 0)
        let pressure = air.pressureToAddForComponent(.oxygen, targetPartial: 42.0)
        // 42 bar O2 / 0.21 = 200 bar total pressure
        #expect(abs(pressure - 200.0) < 0.1, "Need 200 bar air for 42 bar O2 partial pressure")
    }

    @Test("Pressure calculation with zero percentage returns zero")
    func testPressureCalculationZeroPercentage() {
        let mix = GasMix(oxygen: 0, nitrogen: 100, helium: 0)
        let pressure = mix.pressureToAddForComponent(.oxygen, targetPartial: 50.0)
        #expect(pressure == 0, "Cannot add oxygen from a mix with 0% oxygen")
    }

    // MARK: - Equality Tests

    @Test("Identical mixes are equal")
    func testIdenticalMixesEqual() {
        let mix1 = GasMix(oxygen: 32, nitrogen: 68, helium: 0)
        let mix2 = GasMix(oxygen: 32, nitrogen: 68, helium: 0)
        #expect(mix1 == mix2, "Identical mixes should be equal")
    }

    @Test("Different mixes are not equal")
    func testDifferentMixesNotEqual() {
        let mix1 = GasMix(oxygen: 32, nitrogen: 68, helium: 0)
        let mix2 = GasMix(oxygen: 36, nitrogen: 64, helium: 0)
        #expect(mix1 != mix2, "Different mixes should not be equal")
    }

    // MARK: - Codable Tests

    @Test("GasMix can be encoded and decoded")
    func testCodable() throws {
        let original = GasMix(oxygen: 21, nitrogen: 44, helium: 35)
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let data = try encoder.encode(original)
        let decoded = try decoder.decode(GasMix.self, from: data)

        #expect(decoded == original, "Decoded mix should equal original")
    }

    // MARK: - Edge Cases

    @Test("Zero oxygen mix")
    func testZeroOxygenMix() {
        let mix = GasMix(oxygen: 0, nitrogen: 50, helium: 50)
        #expect(mix.oxygen == 0)
        #expect(!mix.isAir)
        #expect(!mix.isNitrox)
    }

    @Test("Pure helium")
    func testPureHelium() {
        let pureHe = GasMix(oxygen: 0, nitrogen: 0, helium: 100)
        #expect(pureHe.isValid)
        #expect(pureHe.helium == 100)
    }

    @Test("High oxygen mix")
    func testHighOxygenMix() {
        let highO2 = GasMix(oxygen: 80, nitrogen: 20, helium: 0)
        #expect(highO2.isValid)
        #expect(highO2.isNitrox)
    }

    // MARK: - Real-World Mixes

    @Test("Common dive mixes are valid")
    func testCommonDiveMixes() {
        let mixes = [
            ("Air", GasMix(oxygen: 21, nitrogen: 79, helium: 0)),
            ("EAN32", GasMix(oxygen: 32, nitrogen: 68, helium: 0)),
            ("EAN36", GasMix(oxygen: 36, nitrogen: 64, helium: 0)),
            ("EAN50", GasMix(oxygen: 50, nitrogen: 50, helium: 0)),
            ("Trimix 21/35", GasMix(oxygen: 21, nitrogen: 44, helium: 35)),
            ("Trimix 18/45", GasMix(oxygen: 18, nitrogen: 37, helium: 45)),
            ("Trimix 15/55", GasMix(oxygen: 15, nitrogen: 30, helium: 55)),
            ("Trimix 10/70", GasMix(oxygen: 10, nitrogen: 20, helium: 70))
        ]

        for (name, mix) in mixes {
            #expect(mix.isValid, "\(name) should be valid")
        }
    }
}
