import Foundation
import CoreLocation

enum UVServiceError: LocalizedError {
    case dataUnavailable
    case locationDenied
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .dataUnavailable:
            return "UV data unavailable. Please check your internet connection."
        case .locationDenied:
            return "Location access denied. Please enable in Settings to get accurate UV data."
        case .networkError:
            return "Network error. Please try again later."
        }
    }
}

struct CachedUVData: Codable {
    let uvData: UVData
    let timestamp: Date
    let location: LocationCoordinate
    
    struct LocationCoordinate: Codable {
        let latitude: Double
        let longitude: Double
    }
    
    var isValid: Bool {
        let cacheValidityDuration: TimeInterval = 15 * 60
        return Date().timeIntervalSince(timestamp) < cacheValidityDuration
    }
    
    func isNearLocation(latitude lat: Double, longitude lon: Double) -> Bool {
        let threshold: Double = 0.01
        return abs(location.latitude - lat) < threshold &&
               abs(location.longitude - lon) < threshold
    }
}

class UVDataService: ObservableObject {
    @Published var currentUVData: UVData?
    @Published var isLoading: Bool = false
    @Published var error: UVServiceError?
    @Published var lastUpdateTime: Date?
    
    private let weatherKitService = WeatherKitService()
    private let openMeteoService = OpenMeteoService()
    private var shouldFallbackToOpenMeteo = false
    
    private let cacheKey = "cachedUVData"
    private let userDefaults = UserDefaults.standard
    
    func fetchUVIndex(for location: CLLocation) async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        if let cachedData = loadCachedData(for: location) {
            await MainActor.run {
                self.currentUVData = cachedData.uvData
                self.lastUpdateTime = cachedData.timestamp
                self.isLoading = false
            }
            
            if cachedData.isValid {
                return
            }
        }
        
        if !shouldFallbackToOpenMeteo {
            do {
                let uvData = try await weatherKitService.fetchWeatherData(for: location)
                cacheData(uvData, for: location)
                await MainActor.run {
                    self.currentUVData = uvData
                    self.lastUpdateTime = Date()
                    self.isLoading = false
                }
                return
            } catch {
                shouldFallbackToOpenMeteo = true
            }
        }
        
        do {
            let uvData = try await openMeteoService.fetchWeatherData(for: location)
            cacheData(uvData, for: location)
            await MainActor.run {
                self.currentUVData = uvData
                self.lastUpdateTime = Date()
                self.isLoading = false
            }
        } catch {
            if let cachedData = loadCachedData(for: location, ignoreValidity: true) {
                await MainActor.run {
                    self.currentUVData = cachedData.uvData
                    self.lastUpdateTime = cachedData.timestamp
                    self.error = nil
                    self.isLoading = false
                }
            } else {
                await MainActor.run {
                    self.error = .dataUnavailable
                    self.isLoading = false
                }
            }
        }
    }
    
    func refreshData(for location: CLLocation) async {
        shouldFallbackToOpenMeteo = false
        await fetchUVIndex(for: location)
    }
    
    private func cacheData(_ uvData: UVData, for location: CLLocation) {
        let cachedData = CachedUVData(
            uvData: uvData,
            timestamp: Date(),
            location: CachedUVData.LocationCoordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        )
        
        if let encoded = try? JSONEncoder().encode(cachedData) {
            userDefaults.set(encoded, forKey: cacheKey)
        }
    }
    
    private func loadCachedData(for location: CLLocation, ignoreValidity: Bool = false) -> CachedUVData? {
        guard let data = userDefaults.data(forKey: cacheKey),
              let cachedData = try? JSONDecoder().decode(CachedUVData.self, from: data) else {
            return nil
        }
        
        let isNearLocation = cachedData.isNearLocation(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
        
        if !isNearLocation {
            return nil
        }
        
        if ignoreValidity {
            return cachedData
        }
        
        return cachedData.isValid ? cachedData : nil
    }
    
    func clearCache() {
        userDefaults.removeObject(forKey: cacheKey)
    }
}
