import Foundation

struct UVData: Codable, Equatable {
    let uvIndex: Double
    let temperature: Double
    let cloudCover: Double
    let locationName: String
    let timestamp: Date
    let dataSource: String
    
    var uvLevel: String {
        switch uvIndex {
        case 0..<3: return "Low"
        case 3..<6: return "Moderate"
        case 6..<8: return "High"
        case 8..<11: return "Very High"
        default: return "Extreme"
        }
    }
    
    var uvLevelColor: String {
        switch uvIndex {
        case 0..<3: return "green"
        case 3..<6: return "yellow"
        case 6..<8: return "orange"
        case 8..<11: return "red"
        default: return "purple"
        }
    }
    
    var displayUVIndex: String {
        String(format: "%.1f", uvIndex)
    }
    
    var displayTemperature: String {
        String(format: "%.0f°C", temperature)
    }
    
    var displayCloudCover: String {
        String(format: "%.0f%%", cloudCover * 100)
    }
    
    var lastUpdatedText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
