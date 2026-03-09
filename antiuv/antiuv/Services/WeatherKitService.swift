import Foundation
import CoreLocation
import WeatherKit

enum WeatherKitServiceError: LocalizedError {
    case authorizationFailed
    case dataUnavailable
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .authorizationFailed:
            return "WeatherKit authorization failed. Check your Apple Developer account."
        case .dataUnavailable:
            return "Weather data unavailable for this location."
        case .unknown(let error):
            return "WeatherKit error: \(error.localizedDescription)"
        }
    }
}

class WeatherKitService {
    
    private let weatherService = WeatherService()
    
    func fetchWeatherData(for location: CLLocation) async throws -> UVData {
        do {
            let weather = try await weatherService.weather(for: location)
            
            let uvIndex = Double(weather.currentWeather.uvIndex.value)
            let temperature = Double(weather.currentWeather.temperature.converted(to: .celsius).value)
            let cloudCover = Double(weather.currentWeather.cloudCover)
            let locationName = try await reverseGeocode(location: location)
            
            return UVData(
                uvIndex: uvIndex,
                temperature: temperature,
                cloudCover: cloudCover,
                locationName: locationName,
                timestamp: Date(),
                dataSource: "WeatherKit"
            )
            
        } catch {
            throw WeatherKitServiceError.unknown(error)
        }
    }
    
    private func reverseGeocode(location: CLLocation) async throws -> String {
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                return "Current Location"
            }
            
            var components: [String] = []
            if let city = placemark.locality {
                components.append(city)
            }
            if let state = placemark.administrativeArea {
                components.append(state)
            }
            if let country = placemark.country {
                components.append(country)
            }
            
            return components.joined(separator: ", ")
        } catch {
            return "Current Location"
        }
    }
}
