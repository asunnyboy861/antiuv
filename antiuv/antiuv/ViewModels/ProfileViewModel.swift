import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile
    @Published var isSaved: Bool = false
    
    private let userDefaultsKey = "userProfile"
    
    init() {
        self.userProfile = UserProfile.default
        loadProfile()
    }
    
    func updateSkinType(_ skinType: SkinType) {
        userProfile.skinType = skinType
        isSaved = false
    }
    
    func updateSPF(_ spf: Int) {
        userProfile.preferredSPF = spf
        isSaved = false
    }
    
    func updateActivityLevel(_ activityLevel: ActivityLevel) {
        userProfile.activityLevel = activityLevel
        isSaved = false
    }
    
    func updateWaterResistant(_ isWaterResistant: Bool) {
        userProfile.isWaterResistant = isWaterResistant
        isSaved = false
    }
    
    func updateNotificationEnabled(_ enabled: Bool) {
        userProfile.notificationEnabled = enabled
        isSaved = false
    }
    
    func updateMorningBriefingEnabled(_ enabled: Bool) {
        userProfile.morningBriefingEnabled = enabled
        isSaved = false
    }
    
    func updateUVAlertThreshold(_ threshold: Double) {
        userProfile.uvAlertThreshold = threshold
        isSaved = false
    }
    
    func saveProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
            isSaved = true
        }
    }
    
    func loadProfile() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey) else {
            return
        }
        
        if let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.userProfile = profile
            isSaved = true
        }
    }
    
    func resetToDefault() {
        userProfile = UserProfile.default
        isSaved = false
    }
    
    var isValid: Bool {
        true
    }
}
