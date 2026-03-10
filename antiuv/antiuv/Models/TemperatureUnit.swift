import Foundation

/// Temperature unit enumeration
/// 
/// Automatically selects the appropriate temperature unit based on user's region:
/// - United States: Fahrenheit (°F)
/// - Australia/New Zealand: Celsius (°C)
///
/// ## Usage Example
/// ```swift
/// let unit = TemperatureUnit.default()
/// let fahrenheit = unit.convert(from: 25.0)
/// ```
enum TemperatureUnit: String, Codable, CaseIterable {
    case celsius = "C"
    case fahrenheit = "F"
    
    var symbol: String {
        switch self {
        case .celsius: return "°C"
        case .fahrenheit: return "°F"
        }
    }
    
    /// Automatically select unit based on region
    static func `default`(for locale: Locale = .current) -> TemperatureUnit {
        if locale.region?.identifier == "US" {
            return .fahrenheit
        } else {
            return .celsius
        }
    }
    
    /// Convert Celsius to target unit
    func convert(from celsius: Double) -> Double {
        switch self {
        case .celsius: return celsius
        case .fahrenheit: return (celsius * 9/5) + 32
        }
    }
}

// MARK: - UVData Extension for Localized Temperature
extension UVData {
    /// Display temperature with automatic region-based unit selection
    var displayTemperatureLocalized: String {
        displayTemperature(in: .default())
    }
    
    /// Display temperature with specified unit
    func displayTemperature(in unit: TemperatureUnit) -> String {
        let converted = unit.convert(from: temperature)
        return String(format: "%.0f%@", converted, unit.symbol)
    }
}
