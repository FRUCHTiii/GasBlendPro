import Testing
@testable import GasBlendPro

struct UnitConversionTests {
    // MARK: - Pressure Conversion Tests

    @Test("Bar to PSI conversion")
    func testBarToPSI() {
        // Test known conversions
        #expect(abs(UnitConversion.barToPSI(1.0) - 14.5038) < 0.0001)
        #expect(abs(UnitConversion.barToPSI(10.0) - 145.038) < 0.001)
        #expect(abs(UnitConversion.barToPSI(100.0) - 1450.38) < 0.01)
        #expect(abs(UnitConversion.barToPSI(200.0) - 2900.76) < 0.01)
        #expect(abs(UnitConversion.barToPSI(300.0) - 4351.14) < 0.01)

        // Test edge cases
        #expect(UnitConversion.barToPSI(0.0) == 0.0)
    }

    @Test("PSI to Bar conversion")
    func testPSIToBar() {
        // Test known conversions
        #expect(abs(UnitConversion.psiToBar(14.5038) - 1.0) < 0.0001)
        #expect(abs(UnitConversion.psiToBar(145.038) - 10.0) < 0.001)
        #expect(abs(UnitConversion.psiToBar(1450.38) - 100.0) < 0.01)
        #expect(abs(UnitConversion.psiToBar(2900.76) - 200.0) < 0.01)
        #expect(abs(UnitConversion.psiToBar(4351.14) - 300.0) < 0.01)

        // Test edge cases
        #expect(UnitConversion.psiToBar(0.0) == 0.0)
    }

    @Test("Round-trip pressure conversion (Bar -> PSI -> Bar)")
    func testPressureRoundTripBarPSI() {
        let testValues = [0.0, 1.0, 50.0, 100.0, 150.0, 200.0, 250.0, 300.0]

        for bar in testValues {
            let psi = UnitConversion.barToPSI(bar)
            let backToBar = UnitConversion.psiToBar(psi)
            #expect(abs(backToBar - bar) < 0.0001, "Round-trip failed for \(bar) bar")
        }
    }

    @Test("Round-trip pressure conversion (PSI -> Bar -> PSI)")
    func testPressureRoundTripPSIBar() {
        let testValues = [0.0, 14.5, 100.0, 500.0, 1000.0, 2000.0, 3000.0, 4000.0]

        for psi in testValues {
            let bar = UnitConversion.psiToBar(psi)
            let backToPSI = UnitConversion.barToPSI(bar)
            #expect(abs(backToPSI - psi) < 0.0001, "Round-trip failed for \(psi) psi")
        }
    }

    @Test("Pressure from bar to display unit")
    func testPressureFromBarToUnit() {
        // Test bar to bar (no conversion)
        #expect(UnitConversion.pressure(fromBar: 200.0, to: .bar) == 200.0)

        // Test bar to PSI
        let psiValue = UnitConversion.pressure(fromBar: 200.0, to: .psi)
        #expect(abs(psiValue - 2900.76) < 0.01)
    }

    @Test("Pressure from display unit to bar")
    func testPressureFromUnitToBar() {
        // Test bar to bar (no conversion)
        #expect(UnitConversion.pressure(fromUnit: .bar, value: 200.0) == 200.0)

        // Test PSI to bar
        let barValue = UnitConversion.pressure(fromUnit: .psi, value: 2900.76)
        #expect(abs(barValue - 200.0) < 0.01)
    }

    // MARK: - Temperature Conversion Tests

    @Test("Celsius to Fahrenheit conversion")
    func testCelsiusToFahrenheit() {
        // Test known conversions
        #expect(abs(UnitConversion.celsiusToFahrenheit(0.0) - 32.0) < 0.1)
        #expect(abs(UnitConversion.celsiusToFahrenheit(20.0) - 68.0) < 0.1)
        #expect(abs(UnitConversion.celsiusToFahrenheit(100.0) - 212.0) < 0.1)
        #expect(abs(UnitConversion.celsiusToFahrenheit(-40.0) - (-40.0)) < 0.1) // Special case

        // Test typical diving temperatures
        #expect(abs(UnitConversion.celsiusToFahrenheit(10.0) - 50.0) < 0.1)
        #expect(abs(UnitConversion.celsiusToFahrenheit(25.0) - 77.0) < 0.1)
        #expect(abs(UnitConversion.celsiusToFahrenheit(30.0) - 86.0) < 0.1)
    }

    @Test("Fahrenheit to Celsius conversion")
    func testFahrenheitToCelsius() {
        // Test known conversions
        #expect(abs(UnitConversion.fahrenheitToCelsius(32.0) - 0.0) < 0.1)
        #expect(abs(UnitConversion.fahrenheitToCelsius(68.0) - 20.0) < 0.1)
        #expect(abs(UnitConversion.fahrenheitToCelsius(212.0) - 100.0) < 0.1)
        #expect(abs(UnitConversion.fahrenheitToCelsius(-40.0) - (-40.0)) < 0.1) // Special case

        // Test typical diving temperatures
        #expect(abs(UnitConversion.fahrenheitToCelsius(50.0) - 10.0) < 0.1)
        #expect(abs(UnitConversion.fahrenheitToCelsius(77.0) - 25.0) < 0.1)
        #expect(abs(UnitConversion.fahrenheitToCelsius(86.0) - 30.0) < 0.1)
    }

    @Test("Round-trip temperature conversion (C -> F -> C)")
    func testTemperatureRoundTripCelsiusFahrenheit() {
        let testValues = [-40.0, 0.0, 10.0, 20.0, 25.0, 30.0, 100.0]

        for celsius in testValues {
            let fahrenheit = UnitConversion.celsiusToFahrenheit(celsius)
            let backToCelsius = UnitConversion.fahrenheitToCelsius(fahrenheit)
            #expect(abs(backToCelsius - celsius) < 0.01, "Round-trip failed for \(celsius)°C")
        }
    }

    @Test("Round-trip temperature conversion (F -> C -> F)")
    func testTemperatureRoundTripFahrenheitCelsius() {
        let testValues = [-40.0, 32.0, 50.0, 68.0, 77.0, 86.0, 212.0]

        for fahrenheit in testValues {
            let celsius = UnitConversion.fahrenheitToCelsius(fahrenheit)
            let backToFahrenheit = UnitConversion.celsiusToFahrenheit(celsius)
            #expect(abs(backToFahrenheit - fahrenheit) < 0.01, "Round-trip failed for \(fahrenheit)°F")
        }
    }

    @Test("Temperature from Celsius to display unit")
    func testTemperatureFromCelsiusToUnit() {
        // Test Celsius to Celsius (no conversion)
        #expect(UnitConversion.temperature(fromCelsius: 20.0, to: .celsius) == 20.0)

        // Test Celsius to Fahrenheit
        let fahrenheit = UnitConversion.temperature(fromCelsius: 20.0, to: .fahrenheit)
        #expect(abs(fahrenheit - 68.0) < 0.1)
    }

    @Test("Temperature from display unit to Celsius")
    func testTemperatureFromUnitToCelsius() {
        // Test Celsius to Celsius (no conversion)
        #expect(UnitConversion.temperature(fromUnit: .celsius, value: 20.0) == 20.0)

        // Test Fahrenheit to Celsius
        let celsius = UnitConversion.temperature(fromUnit: .fahrenheit, value: 68.0)
        #expect(abs(celsius - 20.0) < 0.1)
    }

    // MARK: - Formatting Tests

    @Test("Format pressure in bar")
    func testFormatPressureBar() {
        let formatted = UnitConversion.formatPressure(200.0, unit: .bar)
        #expect(formatted.contains("200"))
        #expect(formatted.contains("bar"))

        let formatted2 = UnitConversion.formatPressure(150.5, unit: .bar)
        #expect(formatted2.contains("bar"))
        #expect(!formatted2.contains(".") || formatted2.contains("150.5")) // Either no decimal or explicit

        let formatted3 = UnitConversion.formatPressure(150.5, unit: .bar, precision: 1)
        #expect(formatted3.contains("150.5"))
        #expect(formatted3.contains("bar"))
    }

    @Test("Format pressure in PSI")
    func testFormatPressurePSI() {
        let formatted = UnitConversion.formatPressure(200.0, unit: .psi)
        #expect(formatted.contains("2900")) // Should show PSI value
        #expect(formatted.contains("psi"))

        // Check decimal precision (default 1 for PSI)
        let formatted2 = UnitConversion.formatPressure(100.0, unit: .psi)
        #expect(formatted2.contains(".")) // Should have decimal point
    }

    @Test("Format temperature in Celsius")
    func testFormatTemperatureCelsius() {
        let formatted = UnitConversion.formatTemperature(20.0, unit: .celsius)
        #expect(formatted.contains("20"))
        #expect(formatted.contains("°C"))

        let formatted2 = UnitConversion.formatTemperature(20.5, unit: .celsius)
        #expect(formatted2.contains("°C"))
        #expect(!formatted2.contains(".") || formatted2.contains("20.5")) // Either no decimal or explicit

        let formatted3 = UnitConversion.formatTemperature(20.5, unit: .celsius, precision: 1)
        #expect(formatted3.contains("20.5"))
        #expect(formatted3.contains("°C"))
    }

    @Test("Format temperature in Fahrenheit")
    func testFormatTemperatureFahrenheit() {
        let formatted = UnitConversion.formatTemperature(20.0, unit: .fahrenheit)
        #expect(formatted == "68°F")

        let formatted2 = UnitConversion.formatTemperature(20.5, unit: .fahrenheit)
        #expect(formatted2.contains("°F"))
    }

    // MARK: - Real-world Scenarios

    @Test("Typical diving tank pressure conversions")
    func testTypicalDivingPressures() {
        // 200 bar (common European tank pressure)
        let psi200bar = UnitConversion.barToPSI(200.0)
        #expect(abs(psi200bar - 2900.76) < 1.0)

        // 3000 PSI (common US tank pressure)
        let bar3000psi = UnitConversion.psiToBar(3000.0)
        #expect(abs(bar3000psi - 206.84) < 1.0)

        // 232 bar (common HP tank pressure)
        let psi232bar = UnitConversion.barToPSI(232.0)
        #expect(abs(psi232bar - 3364.88) < 1.0)
    }

    @Test("Typical dive shop temperatures")
    func testTypicalDiveShopTemperatures() {
        // 20°C (standard condition)
        let f20c = UnitConversion.celsiusToFahrenheit(20.0)
        #expect(abs(f20c - 68.0) < 0.5)

        // 25°C (warm shop)
        let f25c = UnitConversion.celsiusToFahrenheit(25.0)
        #expect(abs(f25c - 77.0) < 0.5)

        // 10°C (cold shop)
        let f10c = UnitConversion.celsiusToFahrenheit(10.0)
        #expect(abs(f10c - 50.0) < 0.5)
    }
}
