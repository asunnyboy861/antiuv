import XCTest
@testable import antiuv

final class ActivityLevelTests: XCTestCase {
    
    func testActivityLevelCount() {
        XCTAssertEqual(ActivityLevel.allCases.count, 5)
    }
    
    func testActivityLevelRawValues() {
        XCTAssertEqual(ActivityLevel.sedentary.rawValue, 0)
        XCTAssertEqual(ActivityLevel.lightExercise.rawValue, 1)
        XCTAssertEqual(ActivityLevel.moderateExercise.rawValue, 2)
        XCTAssertEqual(ActivityLevel.intenseExercise.rawValue, 3)
        XCTAssertEqual(ActivityLevel.swimming.rawValue, 4)
    }
    
    func testActivityLevelMultiplier() {
        XCTAssertEqual(ActivityLevel.sedentary.multiplier, 1.0)
        XCTAssertEqual(ActivityLevel.lightExercise.multiplier, 0.8)
        XCTAssertEqual(ActivityLevel.moderateExercise.multiplier, 0.6)
        XCTAssertEqual(ActivityLevel.intenseExercise.multiplier, 0.5)
        XCTAssertEqual(ActivityLevel.swimming.multiplier, 0.4)
    }
    
    func testActivityLevelDisplayName() {
        XCTAssertEqual(ActivityLevel.sedentary.displayName, "Sedentary (Indoor)")
        XCTAssertEqual(ActivityLevel.swimming.displayName, "Swimming/Water Sports")
    }
    
    func testActivityLevelDescription() {
        XCTAssertEqual(ActivityLevel.sedentary.description, "Minimal outdoor activity")
        XCTAssertEqual(ActivityLevel.moderateExercise.description, "Jogging, cycling")
    }
}
