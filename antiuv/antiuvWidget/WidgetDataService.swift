import WidgetKit
import Foundation

/// Widget data service for reading shared data from App Group
struct WidgetDataService {
    private let userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv") ?? UserDefaults.standard
    }
    
    /// Get UV data from App Group
    func getUVData() -> (uvIndex: Double, uvLevel: String, location: String)? {
        guard let uvIndex = userDefaults.object(forKey: "uvIndex") as? Double?,
              let uvLevel = userDefaults.string(forKey: "uvLevel"),
              let location = userDefaults.string(forKey: "location") else {
            return nil
        }
        
        guard let actualUvIndex = uvIndex else {
            return nil
        }
        
        return (actualUvIndex, uvLevel, location)
    }
    
    /// Check if data is stale
    func isDataStale(freshnessInterval: TimeInterval = 300) -> Bool {
        guard let lastUpdated = userDefaults.object(forKey: "lastUpdated") as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastUpdated) > freshnessInterval
    }
    
    /// Get last updated time as relative text
    func lastUpdatedText() -> String {
        guard let lastUpdated = userDefaults.object(forKey: "lastUpdated") as? Date else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
}
