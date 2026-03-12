import Foundation
import BackgroundTasks
import CoreLocation

class BackgroundTasksService: NSObject {
    static let shared = BackgroundTasksService()
    
    private let uvDataService = UVDataService()
    private let notificationService = NotificationService()
    private var locationManager: CLLocationManager?
    
    private let refreshTaskIdentifier = "com.zzsutuo.antiuv.refresh"
    private let processingTaskIdentifier = "com.zzsutuo.antiuv.processing"
    
    private override init() {
        super.init()
    }
    
    func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: processingTaskIdentifier,
            using: nil
        ) { task in
            self.handleProcessing(task: task as! BGProcessingTask)
        }
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh scheduled successfully")
        } catch {
            print("Could not schedule background refresh: \(error)")
        }
    }
    
    func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: processingTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background processing scheduled successfully")
        } catch {
            print("Could not schedule background processing: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        Task {
            do {
                if let location = getLastKnownLocation() {
                    await uvDataService.fetchUVIndex(for: location)
                    
                    if let uvData = uvDataService.currentUVData {
                        await saveUVDataToAppGroup(uvData)
                        
                        if uvData.uvIndex >= 8.0 {
                            try await notificationService.scheduleUVWarning(uvIndex: uvData.uvIndex)
                        }
                    }
                }
                
                await MainActor.run {
                    task.setTaskCompleted(success: true)
                }
                
                scheduleAppRefresh()
            } catch {
                print("Background refresh failed: \(error)")
                await MainActor.run {
                    task.setTaskCompleted(success: false)
                }
            }
        }
    }
    
    private func handleProcessing(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        Task {
            do {
                if let location = getLastKnownLocation() {
                    await uvDataService.fetchUVIndex(for: location)
                    
                    if let uvData = uvDataService.currentUVData {
                        await saveUVDataToAppGroup(uvData)
                    }
                }
                
                await MainActor.run {
                    task.setTaskCompleted(success: true)
                }
                
                scheduleProcessingTask()
            } catch {
                print("Background processing failed: \(error)")
                await MainActor.run {
                    task.setTaskCompleted(success: false)
                }
            }
        }
    }
    
    private func getLastKnownLocation() -> CLLocation? {
        let userDefaults = UserDefaults.standard
        if let lat = userDefaults.object(forKey: "lastLatitude") as? Double,
           let lon = userDefaults.object(forKey: "lastLongitude") as? Double {
            return CLLocation(latitude: lat, longitude: lon)
        }
        return nil
    }
    
    private func saveUVDataToAppGroup(_ uvData: UVData) async {
        let userDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv")
        
        userDefaults?.set(uvData.uvIndex, forKey: "uvIndex")
        userDefaults?.set(uvData.uvLevel, forKey: "uvLevel")
        userDefaults?.set(uvData.locationName, forKey: "location")
        userDefaults?.set(Date(), forKey: "lastUpdated")
        userDefaults?.synchronize()
    }
}
