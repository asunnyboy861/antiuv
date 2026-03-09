import XCTest
@testable import antiuv

final class SkinTypeTests: XCTestCase {
    
    func testSkinTypeCount() {
        XCTAssertEqual(SkinType.allCases.count, 6)
    }
    
    func testSkinTypeRawValues() {
        XCTAssertEqual(SkinType.typeI.rawValue, 1)
        XCTAssertEqual(SkinType.typeII.rawValue, 2)
        XCTAssertEqual(SkinType.typeIII.rawValue, 3)
        XCTAssertEqual(SkinType.typeIV.rawValue, 4)
        XCTAssertEqual(SkinType.typeV.rawValue, 5)
        XCTAssertEqual(SkinType.typeVI.rawValue, 6)
    }
    
    func testSkinTypeMultiplier() {
        XCTAssertEqual(SkinType.typeI.multiplier, 1.5)
        XCTAssertEqual(SkinType.typeII.multiplier, 1.2)
        XCTAssertEqual(SkinType.typeIII.multiplier, 1.0)
        XCTAssertEqual(SkinType.typeIV.multiplier, 0.8)
        XCTAssertEqual(SkinType.typeV.multiplier, 0.6)
        XCTAssertEqual(SkinType.typeVI.multiplier, 0.5)
    }
    
    func testSkinTypeBaseMED() {
        XCTAssertEqual(SkinType.typeI.baseMED, 15)
        XCTAssertEqual(SkinType.typeII.baseMED, 20)
        XCTAssertEqual(SkinType.typeIII.baseMED, 30)
        XCTAssertEqual(SkinType.typeIV.baseMED, 40)
        XCTAssertEqual(SkinType.typeV.baseMED, 60)
        XCTAssertEqual(SkinType.typeVI.baseMED, 90)
    }
    
    func testSkinTypeDisplayName() {
        XCTAssertEqual(SkinType.typeI.displayName, "Type I - Very Fair")
        XCTAssertEqual(SkinType.typeII.displayName, "Type II - Fair")
        XCTAssertEqual(SkinType.typeIII.displayName, "Type III - Medium")
    }
    
    func testSkinTypeDescription() {
        XCTAssertEqual(SkinType.typeI.description, "Always burns, never tans")
        XCTAssertEqual(SkinType.typeVI.description, "Never burns, deeply pigmented")
    }
}
