import SwiftUI
import UserNotifications

@main
struct antiuvApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        
        Task {
            await setupNotifications()
        }
        
        return true
    }
    
    private func setupNotifications() async {
        do {
            _ = try await NotificationService.shared.requestAuthorization()
            
            if UserDefaults.standard.bool(forKey: "morningBriefingScheduled") == false {
                try? await NotificationService.shared.scheduleMorningBriefing()
                UserDefaults.standard.set(true, forKey: "morningBriefingScheduled")
            }
        } catch {
            print("Notification setup failed: \(error.localizedDescription)")
        }
    }
}
