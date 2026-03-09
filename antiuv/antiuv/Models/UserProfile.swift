import Foundation

struct UserProfile: Codable {
    var skinType: SkinType
    var preferredSPF: Int
    var activityLevel: ActivityLevel
    var isWaterResistant: Bool
    var notificationEnabled: Bool
    var morningBriefingEnabled: Bool
    var uvAlertThreshold: Double
    
    static var `default`: UserProfile {
        UserProfile(
            skinType: .typeII,
            preferredSPF: 50,
            activityLevel: .moderateExercise,
            isWaterResistant: true,
            notificationEnabled: true,
            morningBriefingEnabled: true,
            uvAlertThreshold: 8.0
        )
    }
    
    var displayName: String {
        "Skin Type \(skinType.rawValue) • SPF \(preferredSPF)"
    }
}
