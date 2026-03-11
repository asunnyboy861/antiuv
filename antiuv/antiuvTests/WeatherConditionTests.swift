import XCTest
import SwiftUI
@testable import antiuv

final class WeatherConditionTests: XCTestCase {
    
    func testWeatherConditionRawValues() {
        XCTAssertEqual(WeatherCondition.clear.rawValue, "Clear")
        XCTAssertEqual(WeatherCondition.mostlyClear.rawValue, "MostlyClear")
        XCTAssertEqual(WeatherCondition.partlyCloudy.rawValue, "PartlyCloudy")
        XCTAssertEqual(WeatherCondition.mostlyCloudy.rawValue, "MostlyCloudy")
        XCTAssertEqual(WeatherCondition.cloudy.rawValue, "Cloudy")
        XCTAssertEqual(WeatherCondition.rain.rawValue, "Rain")
        XCTAssertEqual(WeatherCondition.thunderstorm.rawValue, "Thunderstorm")
        XCTAssertEqual(WeatherCondition.snow.rawValue, "Snow")
        XCTAssertEqual(WeatherCondition.foggy.rawValue, "Foggy")
        XCTAssertEqual(WeatherCondition.windy.rawValue, "Windy")
        XCTAssertEqual(WeatherCondition.unknown.rawValue, "Unknown")
    }
    
    func testWeatherConditionDisplayNames() {
        XCTAssertEqual(WeatherCondition.clear.displayName, "Clear")
        XCTAssertEqual(WeatherCondition.mostlyClear.displayName, "Mostly Clear")
        XCTAssertEqual(WeatherCondition.partlyCloudy.displayName, "Partly Cloudy")
        XCTAssertEqual(WeatherCondition.mostlyCloudy.displayName, "Mostly Cloudy")
        XCTAssertEqual(WeatherCondition.cloudy.displayName, "Cloudy")
        XCTAssertEqual(WeatherCondition.rain.displayName, "Rain")
        XCTAssertEqual(WeatherCondition.thunderstorm.displayName, "Thunderstorm")
        XCTAssertEqual(WeatherCondition.snow.displayName, "Snow")
        XCTAssertEqual(WeatherCondition.foggy.displayName, "Foggy")
        XCTAssertEqual(WeatherCondition.windy.displayName, "Windy")
        XCTAssertEqual(WeatherCondition.unknown.displayName, "Unknown")
    }
    
    func testWeatherConditionSystemImages() {
        XCTAssertEqual(WeatherCondition.clear.systemImage, "sun.max")
        XCTAssertEqual(WeatherCondition.mostlyClear.systemImage, "sun.max")
        XCTAssertEqual(WeatherCondition.partlyCloudy.systemImage, "cloud.sun")
        XCTAssertEqual(WeatherCondition.mostlyCloudy.systemImage, "cloud")
        XCTAssertEqual(WeatherCondition.cloudy.systemImage, "cloud")
        XCTAssertEqual(WeatherCondition.rain.systemImage, "cloud.rain")
        XCTAssertEqual(WeatherCondition.thunderstorm.systemImage, "cloud.bolt.rain")
        XCTAssertEqual(WeatherCondition.snow.systemImage, "cloud.snow")
        XCTAssertEqual(WeatherCondition.foggy.systemImage, "cloud.fog")
        XCTAssertEqual(WeatherCondition.windy.systemImage, "wind")
        XCTAssertEqual(WeatherCondition.unknown.systemImage, "questionmark.circle")
    }
    
    func testWeatherConditionColors() {
        XCTAssertNotNil(WeatherCondition.clear.color)
        XCTAssertNotNil(WeatherCondition.rain.color)
        XCTAssertNotNil(WeatherCondition.snow.color)
        XCTAssertNotNil(WeatherCondition.unknown.color)
    }
    
    func testWeatherConditionDecodable() {
        let jsonData = """
        "Clear"
        """.data(using: .utf8)!
        
        let condition = try? JSONDecoder().decode(WeatherCondition.self, from: jsonData)
        XCTAssertEqual(condition, WeatherCondition.clear)
    }
    
    func testWeatherConditionEncodable() {
        let condition = WeatherCondition.partlyCloudy
        let encoded = try? JSONEncoder().encode(condition)
        XCTAssertNotNil(encoded)
        
        let decodedString = String(data: encoded!, encoding: .utf8)
        XCTAssertEqual(decodedString, "\"PartlyCloudy\"")
    }
    
    func testWeatherConditionUnknownFallback() {
        let invalidRawValue = "InvalidCondition"
        let condition = WeatherCondition(rawValue: invalidRawValue)
        XCTAssertNil(condition, "Invalid raw value should return nil")
    }
}

final class UVDataWeatherTests: XCTestCase {
    
    func testUVDataWithWeatherFields() {
        let uvData = UVData(
            uvIndex: 7.5,
            temperature: 25.0,
            cloudCover: 0.3,
            locationName: "Los Angeles, CA, USA",
            timestamp: Date(),
            dataSource: "WeatherKit",
            weatherCondition: .partlyCloudy,
            humidity: 45.0,
            windSpeed: 12.0
        )
        
        XCTAssertEqual(uvData.uvIndex, 7.5)
        XCTAssertEqual(uvData.temperature, 25.0)
        XCTAssertEqual(uvData.cloudCover, 0.3)
        XCTAssertEqual(uvData.locationName, "Los Angeles, CA, USA")
        XCTAssertEqual(uvData.weatherCondition, .partlyCloudy)
        XCTAssertEqual(uvData.humidity, 45.0)
        XCTAssertEqual(uvData.windSpeed, 12.0)
    }
    
    func testUVDataDisplayHumidity() {
        let uvData = UVData(
            uvIndex: 5.0,
            temperature: 20.0,
            cloudCover: 0.5,
            locationName: "Test Location",
            timestamp: Date(),
            dataSource: "Test",
            weatherCondition: .clear,
            humidity: 65.5,
            windSpeed: 10.0
        )
        
        XCTAssertEqual(uvData.displayHumidity, "66%")
    }
    
    func testUVDataDisplayWindSpeed() {
        let uvData = UVData(
            uvIndex: 3.0,
            temperature: 15.0,
            cloudCover: 0.2,
            locationName: "Test Location",
            timestamp: Date(),
            dataSource: "Test",
            weatherCondition: .windy,
            humidity: 50.0,
            windSpeed: 15.7
        )
        
        XCTAssertEqual(uvData.displayWindSpeed, "16 mph")
    }
    
    func testUVDataEquatable() {
        let date = Date()
        let uvData1 = UVData(
            uvIndex: 5.0,
            temperature: 20.0,
            cloudCover: 0.5,
            locationName: "Test",
            timestamp: date,
            dataSource: "Test",
            weatherCondition: .clear,
            humidity: 50.0,
            windSpeed: 10.0
        )
        
        let uvData2 = UVData(
            uvIndex: 5.0,
            temperature: 20.0,
            cloudCover: 0.5,
            locationName: "Test",
            timestamp: date,
            dataSource: "Test",
            weatherCondition: .clear,
            humidity: 50.0,
            windSpeed: 10.0
        )
        
        XCTAssertEqual(uvData1, uvData2, "UVData with same values should be equal")
    }
    
    func testUVDataNotEquatable() {
        let uvData1 = UVData(
            uvIndex: 5.0,
            temperature: 20.0,
            cloudCover: 0.5,
            locationName: "Test",
            timestamp: Date(),
            dataSource: "Test",
            weatherCondition: .clear,
            humidity: 50.0,
            windSpeed: 10.0
        )
        
        let uvData2 = UVData(
            uvIndex: 8.0,
            temperature: 25.0,
            cloudCover: 0.3,
            locationName: "Test",
            timestamp: Date(),
            dataSource: "Test",
            weatherCondition: .rain,
            humidity: 70.0,
            windSpeed: 15.0
        )
        
        XCTAssertNotEqual(uvData1, uvData2, "UVData with different values should not be equal")
    }
}
