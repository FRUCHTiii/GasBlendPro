import Testing
import SwiftData
@testable import GasBlendPro

/// Comprehensive unit tests for Storage Tank functionality
/// Tests tank creation, percentage calculations, deduction logic, and validation
@Suite("Storage Tank Tests")
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

    // MARK: - hasEnoughGas Tests

    @Test("hasEnoughGas - sufficient gas")
    func testHasEnoughGasSufficient() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(tank.hasEnoughGas(pressureNeeded: 100))
        #expect(tank.hasEnoughGas(pressureNeeded: 150))
        #expect(tank.hasEnoughGas(pressureNeeded: 50))
    }

    @Test("hasEnoughGas - insufficient gas")
    func testHasEnoughGasInsufficient() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(!tank.hasEnoughGas(pressureNeeded: 150))
        #expect(!tank.hasEnoughGas(pressureNeeded: 200))
        #expect(!tank.hasEnoughGas(pressureNeeded: 101))
    }

    @Test("hasEnoughGas - exactly enough")
    func testHasEnoughGasExact() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(tank.hasEnoughGas(pressureNeeded: 100))
    }

    @Test("hasEnoughGas - empty tank")
    func testHasEnoughGasEmpty() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 0,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        #expect(!tank.hasEnoughGas(pressureNeeded: 1))
        #expect(tank.hasEnoughGas(pressureNeeded: 0))
    }

    // MARK: - deductUsage Tests

    @Test("deductUsage - normal deduction")
    func testDeductUsageNormal() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        tank.deductUsage(pressureUsed: 50)
        #expect(tank.currentPressure == 100)

        tank.deductUsage(pressureUsed: 25)
        #expect(tank.currentPressure == 75)
    }

    @Test("deductUsage - to empty")
    func testDeductUsageToEmpty() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 100,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        tank.deductUsage(pressureUsed: 100)
        #expect(tank.currentPressure == 0)
    }

    @Test("deductUsage - prevents negative pressure")
    func testDeductUsagePreventsNegative() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 50,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        tank.deductUsage(pressureUsed: 100)
        #expect(tank.currentPressure == 0, "Pressure should not go negative")
    }

    @Test("deductUsage - zero deduction")
    func testDeductUsageZero() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 150,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        tank.deductUsage(pressureUsed: 0)
        #expect(tank.currentPressure == 150)
    }

    @Test("deductUsage - small incremental deductions")
    func testDeductUsageSmallIncrements() throws {
        let tank = StorageTank(
            name: "Test Tank",
            gasType: .oxygen,
            currentPressure: 200,
            maxPressure: 200,
            tankVolume: 50,
            purity: 100.0
        )

        for _ in 1...10 {
            tank.deductUsage(pressureUsed: 5)
        }

        #expect(tank.currentPressure == 150)
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
        #expect(tank.hasEnoughGas(pressureNeeded: 28)) // Typical EAN32 blend from empty

        tank.deductUsage(pressureUsed: 28)
        #expect(tank.currentPressure == 152)
        #expect(abs(tank.percentageFilled - 76.0) < tolerance)
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
        #expect(tank.hasEnoughGas(pressureNeeded: 90)) // Typical trimix blend

        tank.deductUsage(pressureUsed: 90)
        #expect(tank.currentPressure == 160)
        #expect(abs(tank.percentageFilled - 53.33) < 0.1)
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

        // First blend - EAN32
        #expect(tank.hasEnoughGas(pressureNeeded: 28))
        tank.deductUsage(pressureUsed: 28)
        #expect(tank.currentPressure == 172)

        // Second blend - EAN32
        #expect(tank.hasEnoughGas(pressureNeeded: 28))
        tank.deductUsage(pressureUsed: 28)
        #expect(tank.currentPressure == 144)

        // Third blend - EAN36
        #expect(tank.hasEnoughGas(pressureNeeded: 38))
        tank.deductUsage(pressureUsed: 38)
        #expect(tank.currentPressure == 106)

        // Fourth blend - EAN32
        #expect(tank.hasEnoughGas(pressureNeeded: 28))
        tank.deductUsage(pressureUsed: 28)
        #expect(tank.currentPressure == 78)

        // Fifth blend attempt - should still have enough
        #expect(tank.hasEnoughGas(pressureNeeded: 28))
        tank.deductUsage(pressureUsed: 28)
        #expect(tank.currentPressure == 50)

        // Still has 25% left
        #expect(abs(tank.percentageFilled - 25.0) < tolerance)
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

        // Can still do one small blend
        #expect(tank.hasEnoughGas(pressureNeeded: 28))
        #expect(!tank.hasEnoughGas(pressureNeeded: 35))

        tank.deductUsage(pressureUsed: 28)
        #expect(tank.currentPressure == 2)

        // Now critically low - only 1% full
        #expect(tank.percentageFilled < 2.0)
        #expect(!tank.hasEnoughGas(pressureNeeded: 28))
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
        #expect(tank.hasEnoughGas(pressureNeeded: 250))

        tank.deductUsage(pressureUsed: 100)
        #expect(tank.currentPressure == 200)
        #expect(abs(tank.percentageFilled - 50.0) < tolerance)
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
        #expect(tank.hasEnoughGas(pressureNeeded: 25))

        tank.deductUsage(pressureUsed: 25)
        #expect(tank.currentPressure == 25)
        #expect(abs(tank.percentageFilled - 25.0) < tolerance)
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

        tank.deductUsage(pressureUsed: 27.8)
        #expect(abs(tank.currentPressure - 129.5) < tolerance)
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
