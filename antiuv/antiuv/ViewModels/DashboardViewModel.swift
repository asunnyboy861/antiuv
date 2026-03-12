import Foundation
import CoreLocation
import Combine
import UIKit

class DashboardViewModel: NSObject, ObservableObject {
    @Published var uvData: UVData?
    @Published var userProfile: UserProfile
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var safeExposureTime: Int = 0
    @Published var reapplyTime: Int = 0
    @Published var uvAdvice: String = ""
    @Published var shouldShowPermissionExplanation: Bool = false
    
    private let uvDataService = UVDataService()
    private let spfEngine = SPFRecommendationEngine()
    private let locationManager = CLLocationManager()
    private let dataSharingService = DataSharingService.shared
    private let watchConnector = iPhoneWatchConnector.shared
    private var cancellables = Set<AnyCancellable>()
    
    var currentLocation: CLLocation?
    var hasLocationPermission: Bool = false
    
    override init() {
        self.userProfile = UserProfile.default
        super.init()
        setupLocationManager()
        setupDataBindings()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        checkLocationAuthorization()
    }
    
    private func checkLocationAuthorization() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            shouldShowPermissionExplanation = true
        case .authorizedWhenInUse, .authorizedAlways:
            hasLocationPermission = true
            startUpdatingLocation()
        case .denied, .restricted:
            hasLocationPermission = false
            errorMessage = "Location access denied. Please enable in Settings."
        @unknown default:
            break
        }
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
        shouldShowPermissionExplanation = false
    }
    
    func useManualLocation() {
        shouldShowPermissionExplanation = false
    }
    
    func openLocationSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func startUpdatingLocation() {
        locationManager.requestLocation()
    }
    
    private func setupDataBindings() {
        uvDataService.$currentUVData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uvData in
                if let uvData = uvData {
                    self?.uvData = uvData
                    self?.calculateRecommendations(uvIndex: uvData.uvIndex)
                }
            }
            .store(in: &cancellables)
        
        uvDataService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        uvDataService.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.errorMessage = error?.errorDescription
            }
            .store(in: &cancellables)
    }
    
    func fetchUVData() async {
        guard let location = currentLocation else {
            errorMessage = "Waiting for location..."
            return
        }
        
        await uvDataService.fetchUVIndex(for: location)
        
        if let uvData = uvDataService.currentUVData {
            watchConnector.uvData = uvData
            watchConnector.sendUVDataToWatch(uvData)
        }
        
        BackgroundTasksService.shared.scheduleAppRefresh()
    }
    
    func refresh() async {
        await fetchUVData()
    }
    
    private func calculateRecommendations(uvIndex: Double) {
        safeExposureTime = spfEngine.calculateSafeExposureTime(
            uvIndex: uvIndex,
            skinType: userProfile.skinType
        )
        
        reapplyTime = spfEngine.calculateReapplyTime(
            uvIndex: uvIndex,
            spfValue: userProfile.preferredSPF,
            skinType: userProfile.skinType,
            activityLevel: userProfile.activityLevel,
            isWaterResistant: userProfile.isWaterResistant
        )
        
        uvAdvice = spfEngine.getUVAdvice(
            uvIndex: uvIndex,
            skinType: userProfile.skinType
        )
        
        if let uvData = uvData {
            dataSharingService.saveUVData(
                uvIndex: uvData.uvIndex,
                uvLevel: uvData.uvLevel,
                location: uvData.locationName
            )
        }
    }
    
    func updateProfile(_ profile: UserProfile) {
        self.userProfile = profile
        if let uvData = uvData {
            calculateRecommendations(uvIndex: uvData.uvIndex)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension DashboardViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            print("Received location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            Task {
                await fetchUVData()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        errorMessage = "Location error: \(error.localizedDescription)"
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
