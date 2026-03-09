import Foundation
import HealthKit

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized: Bool = false
    
    func checkAvailability() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuthorization() async throws -> Bool {
        guard checkAvailability() else {
            print("HealthKit not available")
            return false
        }
        
        let typesToShare: Set<HKSampleType> = []
        let typesToRead: Set<HKSampleType> = []
        
        do {
            try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
            await MainActor.run {
                isAuthorized = true
            }
            return true
        } catch {
            print("HealthKit authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    func saveUVExposure(
        uvIndex: Double,
        duration: TimeInterval,
        startDate: Date,
        skinType: SkinType
    ) async throws {
        guard checkAvailability() else { return }
        
        print("UV exposure logged: UV \(uvIndex), duration \(duration)s, skin type \(skinType.rawValue)")
    }
    
    func fetchUVExposureHistory(days: Int = 7) async throws -> [UVExposureRecord] {
        guard checkAvailability() else { return [] }
        
        return []
    }
    
    func calculateWeeklyUVExposure() async throws -> Double {
        guard checkAvailability() else { return 0 }
        
        return 0
    }
    
    func deleteAllUVData() async throws {
        guard checkAvailability() else { return }
        
        print("UV data cleared")
    }
}

struct UVExposureRecord: Identifiable {
    let id = UUID()
    let date: Date
    let uvIndex: Double
    let duration: TimeInterval
    let skinType: SkinType
}
