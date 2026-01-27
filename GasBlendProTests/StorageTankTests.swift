import Testing
import SwiftData
@testable import GasBlendPro

/// Comprehensive unit tests for Storage Tank functionality
/// Tests tank creation, percentage calculations, deduction logic, and validation
@Suite("Storage Tank Tests", .serialized)
struct StorageTankTests {
    // MARK: - Test Constants

    private let tolerance = 0.01

    // MARK: - Helper Functions

    /// Creates a test model container with in-memory storage
    private func makeModelContainer() throws -> ModelContainer {
        let schema = Schema([StorageTank.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    // MARK: - Tank Creation Tests

    @Test("Create oxygen tank with valid parameters")
    func testCreateOxygenTank() throws {
        let tank = StorageTank(
            name: "O2 Main",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.5
        )

        #expect(tank.name == "O2 Main")
        #expect(tank.gasType == .oxygen)
        #expect(tank.currentPressure == 150)
        #expect(tank.maxPressure == 200)
        #expect(tank.tankVolume == 50)
        #expect(tank.purity == 99.5)
    }

    @Test("Create helium tank with valid parameters")
    func testCreateHeliumTank() throws {
        let tank = StorageTank(
            name: "He Storage",
            gasType: .helium,
            currentPressure: 100,
            maxPressure: 300,
            tankVolume: 80,
            purity: 100.0
        )

        #expect(tank.name == "He Storage")
        #expect(tank.gasType == .helium)
        #expect(tank.currentPressure == 100)
        #expect(tank.maxPressure == 300)
        #expect(tank.tankVolume == 80)
        #expect(tank.purity == 100.0)
    }

    @Test("Tank has unique ID")
    func testTankHasUniqueID() throws {
        let tank1 = StorageTank(
            name: "Tank 1",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.5
        )

        let tank2 = StorageTank(
            name: "Tank 2",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.5
        )

        #expect(tank1.id != tank2.id)
    }

    // MARK: - Percentage Calculation Tests

    @Test("Calculate percentage filled - 100%")
    func testPercentageFilled100Percent() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 200,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(abs(tank.percentageFilled - 100.0) < tolerance)
    }

    @Test("Calculate percentage filled - 75%")
    func testPercentageFilled75Percent() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(abs(tank.percentageFilled - 75.0) < tolerance)
    }

    @Test("Calculate percentage filled - 50%")
    func testPercentageFilled50Percent() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(abs(tank.percentageFilled - 50.0) < tolerance)
    }

    @Test("Calculate percentage filled - 0% (empty)")
    func testPercentageFilledEmpty() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 0,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(abs(tank.percentageFilled - 0.0) < tolerance)
    }

    @Test("Percentage filled handles zero max pressure")
    func testPercentageFilledZeroMaxPressure() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 0,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(tank.percentageFilled == 0.0)
    }

    // MARK: - hasEnoughGas Tests (Volume-Based)

    @Test("hasEnoughGas - sufficient gas (volume-based with real gas corrections)")
    func testHasEnoughGasSufficient() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        // Tank has 150 bar × 50L = 7500L available (real gas corrected)
        // At 150 bar, Z ≈ 0.985, so we have slightly less than ideal
        #expect(tank.hasEnoughGas(volumeNeeded: 5000)) // Well within capacity
        #expect(tank.hasEnoughGas(volumeNeeded: 2500)) // Well within capacity
        // Note: Real gas corrections mean we might not have exactly 7500L
        #expect(tank.hasEnoughGas(volumeNeeded: 7000)) // Conservative estimate
    }

    @Test("hasEnoughGas - insufficient gas (volume-based)")
    func testHasEnoughGasInsufficient() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        // Tank has 100 bar × 50L = 5000L available
        #expect(!tank.hasEnoughGas(volumeNeeded: 7500)) // Needs 150 bar
        #expect(!tank.hasEnoughGas(volumeNeeded: 10000)) // Needs 200 bar
        #expect(!tank.hasEnoughGas(volumeNeeded: 5050)) // Needs 101 bar
    }

    @Test("hasEnoughGas - exactly enough (volume-based with real gas corrections)")
    func testHasEnoughGasExact() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        // Tank has ~5000L (100 bar × 50L, real gas corrected)
        // At 100 bar, Z ≈ 0.988, so slightly less than ideal
        // Use a conservative volume estimate
        #expect(tank.hasEnoughGas(volumeNeeded: 4900))
    }

    @Test("hasEnoughGas - empty tank (volume-based)")
    func testHasEnoughGasEmpty() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 0,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(!tank.hasEnoughGas(volumeNeeded: 50)) // Needs 1 bar
        #expect(tank.hasEnoughGas(volumeNeeded: 0))
    }

    // MARK: - deductUsage Tests (Volume-Based)

    @Test("deductUsage - normal deduction (volume-based)")
    func testDeductUsageNormal() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        // Use 2500L from 150 bar, Z=0.985
        tank.deductUsage(volumeUsed: 2500)
        #expect(abs(tank.currentPressure - 99.24) < 0.01)

        // Use 1250L from ~99.24 bar, Z≈0.990
        tank.deductUsage(volumeUsed: 1250)
        #expect(abs(tank.currentPressure - 73.99) < 0.01)
    }

    @Test("deductUsage - to empty (volume-based)")
    func testDeductUsageToEmpty() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        // Use all 5000L (100 bar × 50L)
        tank.deductUsage(volumeUsed: 5000)
        #expect(tank.currentPressure == 0)
    }

    @Test("deductUsage - prevents negative pressure (volume-based)")
    func testDeductUsagePreventsNegative() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 50,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        // Try to use 5000L but tank only has 2500L
        tank.deductUsage(volumeUsed: 5000)
        #expect(tank.currentPressure == 0, "Pressure should not go negative")
    }

    @Test("deductUsage - zero deduction (volume-based)")
    func testDeductUsageZero() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        tank.deductUsage(volumeUsed: 0)
        #expect(tank.currentPressure == 150)
    }

    @Test("deductUsage - small incremental deductions (volume-based)")
    func testDeductUsageSmallIncrements() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 200,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        // Use 250L × 10 = 2500L total (Z varies from 0.978 at 200 bar down)
        for _ in 1...10 {
            tank.deductUsage(volumeUsed: 250)
        }

        #expect(abs(tank.currentPressure - 149.04) < 0.01)
    }

    @Test("deductUsage - user's example: 1400L from 50L tank = 28 bar")
    func testDeductUsageUserExample() throws {
        // User's scenario: Fill 7L bottle with 200 bar = 1400L oxygen
        // Storage tank: 50L oxygen tank
        // Ideal: 1400L / 50L = 28 bar deduction
        // Real gas: At 200 bar, Z ≈ 0.978, so slightly more deduction needed
        let tank = StorageTank(
            name: "O2 Storage",
            gasType: .oxygen,
            currentPressure: 200,
            maxPressure: 300,
            tankVolume: 50,
            purity: 100.0
        )

        // Deduct 1400L from 200 bar, Z=0.978
        tank.deductUsage(volumeUsed: 1400)

        // Expected: 200 - (1400/0.978/50) = 171.37 bar
        #expect(abs(tank.currentPressure - 171.37) < 0.01)
    }

    // MARK: - Purity Tests

    @Test("Tank with high purity oxygen")
    func testHighPurityOxygen() throws {
        let tank = StorageTank(
            name: "Medical O2",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.9
        )

        #expect(tank.purity == 99.9)
    }

    @Test("Tank with lower purity oxygen")
    func testLowerPurityOxygen() throws {
        let tank = StorageTank(
            name: "Industrial O2",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 95.0
        )

        #expect(tank.purity == 95.0)
    }

    @Test("Tank with 100% pure helium")
    func testPureHelium() throws {
        let tank = StorageTank(
            name: "Pure He",
            gasType: .helium,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(tank.purity == 100.0)
    }

    // MARK: - Gas Type Label Tests

    @Test("Oxygen tank label")
    func testOxygenLabel() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(tank.gasTypeLabel == "Oxygen")
    }

    @Test("Helium tank label")
    func testHeliumLabel() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .helium,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(tank.gasTypeLabel == "Helium")
    }

    @Test("Air tank label")
    func testAirLabel() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .air,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(tank.gasTypeLabel == "Air")
    }

    // MARK: - Real-World Scenarios

    @Test("Small oxygen tank - typical dive shop")
    func testSmallOxygenTank() throws {
        let tank = StorageTank(
            name: "O2 Small",
            gasType: .oxygen,
            currentPressure: 180,
            maxPressure: 200,
            tankVolume: 10,
            purity: 99.5
        )

        #expect(abs(tank.percentageFilled - 90.0) < tolerance)
        // Typical EAN32 blend needs ~280L
        #expect(tank.hasEnoughGas(volumeNeeded: 280))

        tank.deductUsage(volumeUsed: 280)
        // From 180 bar, Z≈0.9808: 180 - (280/0.9808/10) = 151.45 bar
        #expect(abs(tank.currentPressure - 151.45) < 0.01)
        #expect(abs(tank.percentageFilled - 75.73) < 0.1) // 151.45/200 * 100
    }

    @Test("Large helium bank - technical diving")
    func testLargeHeliumBank() throws {
        let tank = StorageTank(
            name: "He Bank 1",
            gasType: .helium,
            currentPressure: 250,
            maxPressure: 300,
            tankVolume: 80,
            purity: 100.0
        )

        #expect(abs(tank.percentageFilled - 83.33) < 0.1)
        // Typical trimix blend needs 7200L (90 bar × 80L tank)
        #expect(tank.hasEnoughGas(volumeNeeded: 7200))

        tank.deductUsage(volumeUsed: 7200) // Helium Z=1.015 at 250 bar: 7200/1.015/80 = 88.67 bar deduction
        // Expected: 250 - 88.67 = 161.33 bar
        #expect(abs(tank.currentPressure - 161.33) < 0.01)
        #expect(abs(tank.percentageFilled - 53.78) < 0.1) // 161.33/300 * 100 = 53.78%
    }

    @Test("Multiple blends from single tank")
    func testMultipleBlendsFromSingleTank() throws {
        let tank = StorageTank(
            name: "O2 Main",
            gasType: .oxygen,
            currentPressure: 200,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.5
        )

        // First blend - 1400L from 200 bar, Z=0.978
        #expect(tank.hasEnoughGas(volumeNeeded: 1400))
        tank.deductUsage(volumeUsed: 1400)
        #expect(abs(tank.currentPressure - 171.37) < 0.01)

        // Second blend - 1400L from ~171.37 bar, Z≈0.982
        #expect(tank.hasEnoughGas(volumeNeeded: 1400))
        tank.deductUsage(volumeUsed: 1400)
        #expect(abs(tank.currentPressure - 142.86) < 0.01)

        // Third blend - 1900L from ~142.86 bar, Z≈0.986
        #expect(tank.hasEnoughGas(volumeNeeded: 1900))
        tank.deductUsage(volumeUsed: 1900)
        #expect(abs(tank.currentPressure - 104.31) < 0.01)

        // Fourth blend - 1400L from ~104.31 bar, Z≈0.990
        #expect(tank.hasEnoughGas(volumeNeeded: 1400))
        tank.deductUsage(volumeUsed: 1400)
        #expect(abs(tank.currentPressure - 76.01) < 0.01)

        // Fifth blend - 1400L from ~76.01 bar, Z≈0.992
        #expect(tank.hasEnoughGas(volumeNeeded: 1400))
        tank.deductUsage(volumeUsed: 1400)
        #expect(abs(tank.currentPressure - 47.80) < 0.01)

        // ~24% left after 5 blends (47.80/200 * 100 = 23.90%)
        #expect(abs(tank.percentageFilled - 23.90) < 0.1)
    }

    @Test("Tank running low - warning scenario")
    func testTankRunningLow() throws {
        let tank = StorageTank(
            name: "O2 Low",
            gasType: .oxygen,
            currentPressure: 30,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.5
        )

        // Only 15% full
        #expect(abs(tank.percentageFilled - 15.0) < tolerance)

        // Can still do one small blend (1400L = 28 bar × 50L)
        #expect(tank.hasEnoughGas(volumeNeeded: 1400))
        #expect(!tank.hasEnoughGas(volumeNeeded: 1750)) // 35 bar × 50L

        tank.deductUsage(volumeUsed: 1400)
        // Expected: 30 - (1400/0.9985/50) = 1.92 bar
        #expect(abs(tank.currentPressure - 1.92) < 0.01)

        // Now critically low - only 1% full
        #expect(tank.percentageFilled < 2.0)
        #expect(!tank.hasEnoughGas(volumeNeeded: 1400))
    }

    // MARK: - Edge Cases

    @Test("Very large tank")
    func testVeryLargeTank() throws {
        let tank = StorageTank(
            name: "Mega Bank",
            gasType: .oxygen,
            currentPressure: 300,
            maxPressure: 400,
            tankVolume: 200,
            purity: 99.9
        )

        #expect(abs(tank.percentageFilled - 75.0) < tolerance)
        // 50000L = 250 bar × 200L
        #expect(tank.hasEnoughGas(volumeNeeded: 50000))

        tank.deductUsage(volumeUsed: 20000) // O2 Z=0.955 at 300 bar: 20000/0.955/200 = 104.71 bar deduction
        // Expected: 300 - 104.71 = 195.29 bar
        #expect(abs(tank.currentPressure - 195.29) < 0.01)
        #expect(abs(tank.percentageFilled - 48.82) < 0.1) // 195.29/400 * 100 = 48.82%
    }

    @Test("Very small tank")
    func testVerySmallTank() throws {
        let tank = StorageTank(
            name: "Tiny Tank",
            gasType: .oxygen,
            currentPressure: 50,
            maxPressure: 100,
            tankVolume: 1,
            purity: 100.0
        )

        #expect(abs(tank.percentageFilled - 50.0) < tolerance)
        // 25L = 25 bar × 1L
        #expect(tank.hasEnoughGas(volumeNeeded: 25))

        tank.deductUsage(volumeUsed: 25) // O2 Z=0.995 at 50 bar: 25/0.995/1 = 25.13 bar deduction
        // Expected: 50 - 25.13 = 24.87 bar
        #expect(abs(tank.currentPressure - 24.87) < 0.01)
        #expect(abs(tank.percentageFilled - 24.87) < 0.1) // 24.87/100 * 100 = 24.87%
    }

    @Test("Fractional pressure values")
    func testFractionalPressureValues() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 157.3,
            maxPressure: 201.5,
            tankVolume: 50,
            purity: 99.5
        )

        #expect(abs(tank.percentageFilled - 78.06) < 0.1)

        tank.deductUsage(volumeUsed: 1390) // From 157.3 bar, Z≈0.984
        #expect(abs(tank.currentPressure - 129.05) < 0.01)
    }

    // MARK: - Persistence Tests

    @Test("Tank persists to SwiftData")
    func testTankPersistence() throws {
        let container = try makeModelContainer()
        let context = ModelContext(container)

        let tank = StorageTank(
            name: "Persistent Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.5
        )

        context.insert(tank)
        try context.save()

        // Fetch the tank back
        let descriptor = FetchDescriptor<StorageTank>()
        let tanks = try context.fetch(descriptor)

        #expect(tanks.count == 1)
        #expect(tanks.first?.name == "Persistent Tank")
        #expect(tanks.first?.gasType == .oxygen)
        #expect(tanks.first?.currentPressure == 150)
    }

    @Test("Multiple tanks persist correctly")
    func testMultipleTanksPersistence() throws {
        let container = try makeModelContainer()
        let context = ModelContext(container)

        let tank1 = StorageTank(
            name: "O2 Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 99.5
        )

        let tank2 = StorageTank(
            name: "He Tank",
            gasType: .helium,
            currentPressure: 250,
            maxPressure: 300,
            tankVolume: 80,
            purity: 100.0
        )

        context.insert(tank1)
        context.insert(tank2)
        try context.save()

        let descriptor = FetchDescriptor<StorageTank>()
        let tanks = try context.fetch(descriptor)

        #expect(tanks.count == 2)
        #expect(tanks.contains { $0.name == "O2 Tank" })
        #expect(tanks.contains { $0.name == "He Tank" })
    }
}
