import Foundation
import WidgetKit

/// Data sharing service for App Group
/// Used to share UV data between main app and Widget
class DataSharingService {
    static let shared = DataSharingService()
    
    private let userDefaults: UserDefaults
    
    init() {
        guard let groupUserDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv") else {
            fatalError("Unable to access App Group UserDefaults")
        }
        userDefaults = groupUserDefaults
    }
    
    /// Save UV data to App Group (for Widget to read)
    func saveUVData(uvIndex: Double, uvLevel: String, location: String) {
        userDefaults.set(uvIndex, forKey: "uvIndex")
        userDefaults.set(uvLevel, forKey: "uvLevel")
        userDefaults.set(location, forKey: "location")
        userDefaults.set(Date(), forKey: "lastUpdated")
        
        // Force immediate save
        userDefaults.synchronize()
        
        print("✅ UV data saved to App Group: \(uvIndex) - \(uvLevel) - \(location)")
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
    
    /// Check if data exists
    func hasUVData() -> Bool {
        return userDefaults.object(forKey: "uvIndex") != nil
    }
    
    /// Clear all UV data
    func clearUVData() {
        userDefaults.removeObject(forKey: "uvIndex")
        userDefaults.removeObject(forKey: "uvLevel")
        userDefaults.removeObject(forKey: "location")
        userDefaults.removeObject(forKey: "lastUpdated")
        userDefaults.synchronize()
    }
}

// MARK: - Widget Data Freshness
extension DataSharingService {
    /// Check if data is stale
    /// - Parameter freshnessInterval: Freshness threshold in seconds (default: 5 minutes)
    /// - Returns: True if data is older than the threshold
    func isDataStale(freshnessInterval: TimeInterval = 300) -> Bool {
        guard let lastUpdated = userDefaults.object(forKey: "lastUpdated") as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastUpdated) > freshnessInterval
    }
    
    /// Get last updated time as relative text
    /// - Returns: Relative time string (e.g., "2 min ago")
    func lastUpdatedText() -> String {
        guard let lastUpdated = userDefaults.object(forKey: "lastUpdated") as? Date else {
            return "Never"
        }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastUpdated, relativeTo: Date())
    }
    
    /// Trigger Widget refresh
    func refreshWidget() {
        WidgetCenter.shared.reloadTimelines(ofKind: "antiuvWidget")
    }
}
