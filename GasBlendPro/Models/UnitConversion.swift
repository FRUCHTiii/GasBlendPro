import Foundation

/// Unit conversion utilities for pressure and temperature
enum UnitConversion {
    // MARK: - Pressure Conversions

    /// Convert pressure from bar to PSI
    /// - Parameter bar: Pressure in bar
    /// - Returns: Pressure in PSI
    static func barToPSI(_ bar: Double) -> Double {
        bar * 14.5038 // 1 bar = 14.5038 PSI
    }

    /// Convert pressure from PSI to bar
    /// - Parameter psi: Pressure in PSI
    /// - Returns: Pressure in bar
    static func psiToBar(_ psi: Double) -> Double {
        psi / 14.5038
    }

    /// Convert pressure from internal storage (bar) to display unit
    /// - Parameters:
    ///   - bar: Pressure in bar (internal storage)
    ///   - unit: Target pressure unit
    /// - Returns: Pressure in target unit
    static func pressure(fromBar bar: Double, to unit: PressureUnit) -> Double {
        switch unit {
        case .bar:
            return bar
        case .psi:
            return barToPSI(bar)
        }
    }

    /// Convert pressure from display unit to internal storage (bar)
    /// - Parameters:
    ///   - value: Pressure value in display unit
    ///   - unit: Source pressure unit
    /// - Returns: Pressure in bar (for internal storage)
    static func pressure(fromUnit unit: PressureUnit, value: Double) -> Double {
        switch unit {
        case .bar:
            return value
        case .psi:
            return psiToBar(value)
        }
    }

    // MARK: - Temperature Conversions

    /// Convert temperature from Celsius to Fahrenheit
    /// - Parameter celsius: Temperature in Celsius
    /// - Returns: Temperature in Fahrenheit
    static func celsiusToFahrenheit(_ celsius: Double) -> Double {
        (celsius * 9.0 / 5.0) + 32.0
    }

    /// Convert temperature from Fahrenheit to Celsius
    /// - Parameter fahrenheit: Temperature in Fahrenheit
    /// - Returns: Temperature in Celsius
    static func fahrenheitToCelsius(_ fahrenheit: Double) -> Double {
        (fahrenheit - 32.0) * 5.0 / 9.0
    }

    /// Convert temperature from internal storage (Celsius) to display unit
    /// - Parameters:
    ///   - celsius: Temperature in Celsius (internal storage)
    ///   - unit: Target temperature unit
    /// - Returns: Temperature in target unit
    static func temperature(fromCelsius celsius: Double, to unit: TemperatureUnit) -> Double {
        switch unit {
        case .celsius:
            return celsius
        case .fahrenheit:
            return celsiusToFahrenheit(celsius)
        }
    }

    /// Convert temperature from display unit to internal storage (Celsius)
    /// - Parameters:
    ///   - value: Temperature value in display unit
    ///   - unit: Source temperature unit
    /// - Returns: Temperature in Celsius (for internal storage)
    static func temperature(fromUnit unit: TemperatureUnit, value: Double) -> Double {
        switch unit {
        case .celsius:
            return value
        case .fahrenheit:
            return fahrenheitToCelsius(value)
        }
    }

    // MARK: - Formatting Helpers

    /// Format pressure value for display
    /// - Parameters:
    ///   - bar: Pressure in bar (internal storage)
    ///   - unit: Display unit
    ///   - precision: Number of decimal places (default: 0 for bar, 1 for PSI)
    /// - Returns: Formatted string with unit symbol
    static func formatPressure(_ bar: Double, unit: PressureUnit, precision: Int? = nil) -> String {
        let value = pressure(fromBar: bar, to: unit)
        let decimals = precision ?? (unit == .bar ? 0 : 1)
        return String(format: "%.\(decimals)f %@", value, unit.symbol)
    }

    /// Format temperature value for display
    /// - Parameters:
    ///   - celsius: Temperature in Celsius (internal storage)
    ///   - unit: Display unit
    ///   - precision: Number of decimal places (default: 0)
    /// - Returns: Formatted string with unit symbol
    static func formatTemperature(_ celsius: Double, unit: TemperatureUnit, precision: Int = 0) -> String {
        let value = temperature(fromCelsius: celsius, to: unit)
        return String(format: "%.\(precision)f%@", value, unit.symbol)
    }
}
