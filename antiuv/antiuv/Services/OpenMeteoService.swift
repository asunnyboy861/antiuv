import Foundation
import CoreLocation

struct OpenMeteoResponse: Codable {
    let latitude: Double
    let longitude: Double
    let current: CurrentWeather
    let timezone: String
    
    struct CurrentWeather: Codable {
        let time: String
        let uv_index: Double
        let temperature_2m: Double
        let cloud_cover: Double
        let relative_humidity_2m: Int
        let wind_speed_10m: Double
        let weather_code: Int
    }
}

class OpenMeteoService {
    
    func fetchWeatherData(for location: CLLocation) async throws -> UVData {
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current=uv_index,temperature_2m,cloud_cover,relative_humidity_2m,wind_speed_10m,weather_code&timezone=auto") else {
            throw WeatherKitServiceError.dataUnavailable
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WeatherKitServiceError.dataUnavailable
        }
        
        do {
            let openMeteoResponse = try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
            
            let uvIndex = openMeteoResponse.current.uv_index
            let temperature = openMeteoResponse.current.temperature_2m
            let cloudCover = openMeteoResponse.current.cloud_cover / 100.0
            let humidity = Double(openMeteoResponse.current.relative_humidity_2m) / 100.0
            let windSpeed = openMeteoResponse.current.wind_speed_10m * 0.621371
            let weatherCondition = mapWeatherCode(openMeteoResponse.current.weather_code)
            
            let locationName = try await reverseGeocode(location: location)
            
            return UVData(
                uvIndex: uvIndex,
                temperature: temperature,
                cloudCover: cloudCover,
                locationName: locationName,
                timestamp: Date(),
                dataSource: "Open-Meteo",
                weatherCondition: weatherCondition,
                humidity: humidity,
                windSpeed: windSpeed
            )
        } catch {
            throw WeatherKitServiceError.unknown(error)
        }
    }
    
    private func mapWeatherCode(_ code: Int) -> WeatherCondition {
        switch code {
        case 0:
            return .clear
        case 1:
            return .mostlyClear
        case 2:
            return .partlyCloudy
        case 3:
            return .mostlyCloudy
        case 45, 48:
            return .foggy
        case 51, 53, 55, 56, 57:
            return .rain
        case 61, 63, 65, 66, 67:
            return .rain
        case 71, 73, 75, 77:
            return .snow
        case 80, 81, 82, 85, 86:
            return .rain
        case 95, 96, 99:
            return .thunderstorm
        default:
            return .unknown
        }
    }
    
    private func reverseGeocode(location: CLLocation) async throws -> String {
        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(location)
            guard let placemark = placemarks.first else {
                return "Current Location"
            }
            
            var components: [String] = []
            
            // 澳大利亚地区优化：优先显示城市 + 州缩写
            if let countryCode = placemark.isoCountryCode, countryCode == "AU" {
                if let city = placemark.locality {
                    components.append(city)
                }
                if let state = placemark.administrativeArea {
                    components.append(state)
                }
            } else {
                // 其他地区：城市 + 州/省
                if let city = placemark.locality {
                    components.append(city)
                }
                if let state = placemark.administrativeArea {
                    components.append(state)
                }
            }
            
            // 如果没有城市信息，尝试使用subLocality或thoroughfare
            if components.isEmpty {
                if let subLocality = placemark.subLocality {
                    components.append(subLocality)
                } else if let thoroughfare = placemark.thoroughfare {
                    components.append(thoroughfare)
                } else if let country = placemark.country {
                    components.append(country)
                }
            }
            
            return components.isEmpty ? "Current Location" : components.joined(separator: ", ")
        } catch {
            return "Current Location"
        }
    }
}
