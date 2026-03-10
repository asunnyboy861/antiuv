import Foundation
import Testing
@testable import antiuv

struct OnboardingTests {
    
    @Test func testOnboardingPageCreation() async throws {
        let page = OnboardingPage(
            icon: "sun.max.fill",
            color: .orange,
            title: "Test Title",
            description: "Test Description",
            features: ["Feature 1", "Feature 2"]
        )
        
        #expect(page.icon == "sun.max.fill")
        #expect(page.title == "Test Title")
        #expect(page.description == "Test Description")
        #expect(page.features.count == 2)
    }
    
    @Test func testUserProfilePersistence() async throws {
        let profile = UserProfile(
            skinType: .typeII,
            preferredSPF: 30,
            activityLevel: .moderateExercise,
            isWaterResistant: false,
            notificationEnabled: true,
            morningBriefingEnabled: true,
            uvAlertThreshold: 8.0
        )
        
        let encoded = try? JSONEncoder().encode(profile)
        UserDefaults.standard.set(encoded, forKey: "userProfile")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        let savedData = UserDefaults.standard.data(forKey: "userProfile")
        #expect(savedData != nil)
        
        let hasCompleted = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        #expect(hasCompleted == true)
        
        UserDefaults.standard.removeObject(forKey: "userProfile")
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
    
    @Test func testSkinTypeRawValues() async throws {
        #expect(SkinType.typeI.rawValue == 1)
        #expect(SkinType.typeII.rawValue == 2)
        #expect(SkinType.typeIII.rawValue == 3)
        #expect(SkinType.typeIV.rawValue == 4)
        #expect(SkinType.typeV.rawValue == 5)
        #expect(SkinType.typeVI.rawValue == 6)
    }
    
    @Test func testActivityLevelRawValues() async throws {
        #expect(ActivityLevel.sedentary.rawValue == 0)
        #expect(ActivityLevel.lightExercise.rawValue == 1)
        #expect(ActivityLevel.moderateExercise.rawValue == 2)
        #expect(ActivityLevel.intenseExercise.rawValue == 3)
    }
    
    @Test func testUserProfileEncoding() async throws {
        let profile = UserProfile(
            skinType: .typeIII,
            preferredSPF: 50,
            activityLevel: .intenseExercise,
            isWaterResistant: true,
            notificationEnabled: true,
            morningBriefingEnabled: false,
            uvAlertThreshold: 6.0
        )
        
        let encoded = try JSONEncoder().encode(profile)
        let decoded = try JSONDecoder().decode(UserProfile.self, from: encoded)
        
        #expect(decoded.skinType == .typeIII)
        #expect(decoded.preferredSPF == 50)
        #expect(decoded.activityLevel == .intenseExercise)
        #expect(decoded.isWaterResistant == true)
        #expect(decoded.notificationEnabled == true)
        #expect(decoded.morningBriefingEnabled == false)
    }
}
