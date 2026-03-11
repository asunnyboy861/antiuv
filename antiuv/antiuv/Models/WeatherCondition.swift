import Foundation
import SwiftUI

enum WeatherCondition: String, Codable {
    case clear = "Clear"
    case mostlyClear = "MostlyClear"
    case partlyCloudy = "PartlyCloudy"
    case mostlyCloudy = "MostlyCloudy"
    case cloudy = "Cloudy"
    case rain = "Rain"
    case thunderstorm = "Thunderstorm"
    case snow = "Snow"
    case foggy = "Foggy"
    case windy = "Windy"
    case unknown = "Unknown"
    
    var displayName: String {
        switch self {
        case .clear: return "Clear"
        case .mostlyClear: return "Mostly Clear"
        case .partlyCloudy: return "Partly Cloudy"
        case .mostlyCloudy: return "Mostly Cloudy"
        case .cloudy: return "Cloudy"
        case .rain: return "Rain"
        case .thunderstorm: return "Thunderstorm"
        case .snow: return "Snow"
        case .foggy: return "Foggy"
        case .windy: return "Windy"
        case .unknown: return "Unknown"
        }
    }
    
    var systemImage: String {
        switch self {
        case .clear, .mostlyClear: return "sun.max"
        case .partlyCloudy: return "cloud.sun"
        case .mostlyCloudy, .cloudy: return "cloud"
        case .rain: return "cloud.rain"
        case .thunderstorm: return "cloud.bolt.rain"
        case .snow: return "cloud.snow"
        case .foggy: return "cloud.fog"
        case .windy: return "wind"
        case .unknown: return "questionmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .clear, .mostlyClear: return .orange
        case .partlyCloudy: return .yellow
        case .mostlyCloudy, .cloudy: return .gray
        case .rain, .thunderstorm: return .blue
        case .snow: return .cyan
        case .foggy: return .secondary
        case .windy: return .green
        case .unknown: return .secondary
        }
    }
}
