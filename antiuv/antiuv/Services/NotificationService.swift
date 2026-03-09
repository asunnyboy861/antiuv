import Foundation
import UserNotifications

enum NotificationType: String {
    case reapplyReminder = "reapply_reminder"
    case uvPeakAlert = "uv_peak_alert"
    case morningBriefing = "morning_briefing"
    case locationBased = "location_based"
}

class NotificationService: NSObject {
    
    static let shared = NotificationService()
    
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
    }
    
    func requestAuthorization() async throws -> Bool {
        do {
            let granted = try await center.requestAuthorization(
                options: [.alert, .sound, .badge, .criticalAlert]
            )
            
            if granted {
                print("Notification permission granted")
                await registerNotificationCategories()
            } else {
                print("Notification permission denied")
            }
            
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            throw error
        }
    }
    
    private func registerNotificationCategories() async {
        let appliedAction = UNNotificationAction(
            identifier: "APPLIED_ACTION",
            title: "✓ I Applied Sunscreen",
            options: .foreground
        )
        
        let remindLaterAction = UNNotificationAction(
            identifier: "REMIND_LATER_ACTION",
            title: "⏰ Remind in 15 min",
            options: .foreground
        )
        
        let reapplyCategory = UNNotificationCategory(
            identifier: NotificationType.reapplyReminder.rawValue,
            actions: [appliedAction, remindLaterAction],
            intentIdentifiers: [],
            options: []
        )
        
        center.setNotificationCategories([reapplyCategory])
    }
    
    func scheduleReapplyReminder(
        timeInterval: TimeInterval,
        uvIndex: Double,
        spfValue: Int
    ) async throws {
        
        let seconds = timeInterval * 60
        
        let content = UNMutableNotificationContent()
        content.title = "🧴 Time to Reapply!"
        content.body = "UV Index: \(Int(uvIndex)) | SPF \(spfValue) protection ending"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = NotificationType.reapplyReminder.rawValue
        
        content.userInfo = [
            "uvIndex": uvIndex,
            "spfValue": spfValue,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: seconds,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "reapply_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
        print("Reapply reminder scheduled in \(timeInterval) minutes")
    }
    
    func scheduleUVWarning(uvIndex: Double) async throws {
        guard uvIndex >= 8 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Extreme UV Alert!"
        content.body = "UV Index is \(Int(uvIndex)). Stay indoors if possible. Use SPF 50+."
        content.sound = .defaultCritical
        content.categoryIdentifier = NotificationType.uvPeakAlert.rawValue
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "uv_warning_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    func scheduleMorningBriefing() async throws {
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let content = UNMutableNotificationContent()
        content.title = "☀️ Good Morning!"
        content.body = "Check today's UV forecast and plan your sun protection."
        content.sound = .default
        content.categoryIdentifier = NotificationType.morningBriefing.rawValue
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: "morning_briefing",
            content: content,
            trigger: trigger
        )
        
        try await center.add(request)
    }
    
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        print("All notifications cancelled")
    }
    
    func cancelNotification(withIdentifier id: String) {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
    
    func getNotificationSettings() async -> UNNotificationSettings {
        await center.notificationSettings()
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case "APPLIED_ACTION":
            print("User logged sunscreen application")
            
        case "REMIND_LATER_ACTION":
            print("User requested reminder in 15 minutes")
            
        default:
            break
        }
        
        completionHandler()
    }
}
