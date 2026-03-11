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

class UVDataService: ObservableObject {
    @Published var currentUVData: UVData?
    @Published var isLoading: Bool = false
    @Published var error: UVServiceError?
    
    private let weatherKitService = WeatherKitService()
    private let openMeteoService = OpenMeteoService()
    private var shouldFallbackToOpenMeteo = false
    
    func fetchUVIndex(for location: CLLocation) async {
        await MainActor.run {
            isLoading = true
            error = nil
        }
        
        if !shouldFallbackToOpenMeteo {
            do {
                let uvData = try await weatherKitService.fetchWeatherData(for: location)
                await MainActor.run {
                    self.currentUVData = uvData
                    self.isLoading = false
                }
                return
            } catch {
                shouldFallbackToOpenMeteo = true
            }
        }
        
        do {
            let uvData = try await openMeteoService.fetchWeatherData(for: location)
            await MainActor.run {
                self.currentUVData = uvData
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = .dataUnavailable
                self.isLoading = false
            }
        }
    }
    
    func refreshData(for location: CLLocation) async {
        await fetchUVIndex(for: location)
    }
}
