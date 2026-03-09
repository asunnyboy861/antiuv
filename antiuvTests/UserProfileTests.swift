import XCTest
@testable import antiuv

final class UserProfileTests: XCTestCase {
    
    func testDefaultProfile() {
        let profile = UserProfile.default
        
        XCTAssertEqual(profile.skinType, .typeII)
        XCTAssertEqual(profile.preferredSPF, 50)
        XCTAssertEqual(profile.activityLevel, .moderateExercise)
        XCTAssertEqual(profile.isWaterResistant, true)
        XCTAssertEqual(profile.notificationEnabled, true)
        XCTAssertEqual(profile.morningBriefingEnabled, true)
        XCTAssertEqual(profile.uvAlertThreshold, 8.0)
    }
    
    func testProfileDisplayName() {
        let profile = UserProfile(
            skinType: .typeIII,
            preferredSPF: 30,
            activityLevel: .lightExercise,
            isWaterResistant: false,
            notificationEnabled: true,
            morningBriefingEnabled: false,
            uvAlertThreshold: 6.0
        )
        
        XCTAssertEqual(profile.displayName, "Skin Type 3 • SPF 30")
    }
    
    func testProfileCodable() throws {
        let originalProfile = UserProfile(
            skinType: .typeIV,
            preferredSPF: 50,
            activityLevel: .swimming,
            isWaterResistant: true,
            notificationEnabled: false,
            morningBriefingEnabled: true,
            uvAlertThreshold: 10.0
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalProfile)
        
        let decoder = JSONDecoder()
        let decodedProfile = try decoder.decode(UserProfile.self, from: data)
        
        XCTAssertEqual(decodedProfile.skinType, originalProfile.skinType)
        XCTAssertEqual(decodedProfile.preferredSPF, originalProfile.preferredSPF)
        XCTAssertEqual(decodedProfile.activityLevel, originalProfile.activityLevel)
    }
}
