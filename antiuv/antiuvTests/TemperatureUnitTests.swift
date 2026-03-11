import Foundation
import Testing
@testable import antiuv

struct TemperatureUnitTests {
    
    @Test func defaultUnitForUS() async throws {
        let usLocale = Locale(identifier: "en_US")
        let unit = TemperatureUnit.default(for: usLocale)
        #expect(unit == .fahrenheit)
    }
    
    @Test func defaultUnitForAustralia() async throws {
        let auLocale = Locale(identifier: "en_AU")
        let unit = TemperatureUnit.default(for: auLocale)
        #expect(unit == .celsius)
    }
    
    @Test func defaultUnitForNewZealand() async throws {
        let nzLocale = Locale(identifier: "en_NZ")
        let unit = TemperatureUnit.default(for: nzLocale)
        #expect(unit == .celsius)
    }
    
    @Test func celsiusToFahrenheitConversion() async throws {
        let celsius = 25.0
        let expectedFahrenheit = 77.0
        let result = TemperatureUnit.fahrenheit.convert(from: celsius)
        #expect(abs(result - expectedFahrenheit) < 0.1)
    }
    
    @Test func celsiusToCelsiusConversion() async throws {
        let celsius = 25.0
        let result = TemperatureUnit.celsius.convert(from: celsius)
        #expect(abs(result - celsius) < 0.1)
    }
    
    @Test func fahrenheitSymbol() async throws {
        #expect(TemperatureUnit.fahrenheit.symbol == "°F")
    }
    
    @Test func celsiusSymbol() async throws {
        #expect(TemperatureUnit.celsius.symbol == "°C")
    }
    
    @Test func displayTemperatureLocalizedForUS() async throws {
        let uvData = UVData(
            uvIndex: 5.0,
            temperature: 25.0,
            cloudCover: 0.3,
            locationName: "Test",
            timestamp: Date(),
            dataSource: "Test",
            weatherCondition: .clear,
            humidity: 50.0,
            windSpeed: 10.0
        )
        
        let usLocale = Locale(identifier: "en_US")
        let unit = TemperatureUnit.default(for: usLocale)
        let display = uvData.displayTemperature(in: unit)
        
        #expect(display == "77°F")
    }
    
    @Test func displayTemperatureLocalizedForAU() async throws {
        let uvData = UVData(
            uvIndex: 5.0,
            temperature: 25.0,
            cloudCover: 0.3,
            locationName: "Test",
            timestamp: Date(),
            dataSource: "Test",
            weatherCondition: .clear,
            humidity: 50.0,
            windSpeed: 10.0
        )
        
        let auLocale = Locale(identifier: "en_AU")
        let unit = TemperatureUnit.default(for: auLocale)
        let display = uvData.displayTemperature(in: unit)
        
        #expect(display == "25°C")
    }
    
    @Test func displayTemperatureLocalizedMethod() async throws {
        let uvData = UVData(
            uvIndex: 5.0,
            temperature: 25.0,
            cloudCover: 0.3,
            locationName: "Los Angeles, CA",
            timestamp: Date(),
            dataSource: "WeatherKit",
            weatherCondition: .clear,
            humidity: 45.0,
            windSpeed: 8.0
        )
        
        let display = uvData.displayTemperatureLocalized
        #expect(display.contains("°"))
        #expect(display.contains("F") || display.contains("C"))
    }
}
