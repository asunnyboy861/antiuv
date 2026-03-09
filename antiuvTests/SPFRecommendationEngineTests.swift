import XCTest
@testable import antiuv

final class SPFRecommendationEngineTests: XCTestCase {
    
    var engine: SPFRecommendationEngine!
    
    override func setUp() {
        super.setUp()
        engine = SPFRecommendationEngine()
    }
    
    override func tearDown() {
        engine = nil
        super.tearDown()
    }
    
    func testCalculateReapplyTime_Baseline() {
        let time = engine.calculateReapplyTime(
            uvIndex: 5.0,
            spfValue: 50,
            skinType: .typeIII,
            activityLevel: .sedentary,
            isWaterResistant: true
        )
        
        XCTAssertEqual(time, 100)
    }
    
    func testCalculateReapplyTime_HighUV() {
        let time = engine.calculateReapplyTime(
            uvIndex: 10.0,
            spfValue: 50,
            skinType: .typeIII,
            activityLevel: .sedentary,
            isWaterResistant: true
        )
        
        XCTAssertEqual(time, 50)
    }
    
    func testCalculateReapplyTime_FairSkin() {
        let time = engine.calculateReapplyTime(
            uvIndex: 5.0,
            spfValue: 50,
            skinType: .typeII,
            activityLevel: .sedentary,
            isWaterResistant: true
        )
        
        XCTAssertEqual(time, 120)
    }
    
    func testCalculateReapplyTime_DarkSkin() {
        let time = engine.calculateReapplyTime(
            uvIndex: 5.0,
            spfValue: 50,
            skinType: .typeVI,
            activityLevel: .sedentary,
            isWaterResistant: true
        )
        
        XCTAssertEqual(time, 50)
    }
    
    func testCalculateReapplyTime_WithSwimming() {
        let time = engine.calculateReapplyTime(
            uvIndex: 5.0,
            spfValue: 50,
            skinType: .typeIII,
            activityLevel: .swimming,
            isWaterResistant: false
        )
        
        XCTAssertEqual(time, 20)
    }
    
    func testCalculateReapplyTime_MinimumClamp() {
        let time = engine.calculateReapplyTime(
            uvIndex: 15.0,
            spfValue: 15,
            skinType: .typeVI,
            activityLevel: .swimming,
            isWaterResistant: false
        )
        
        XCTAssertEqual(time, 15)
    }
    
    func testCalculateReapplyTime_MaximumClamp() {
        let time = engine.calculateReapplyTime(
            uvIndex: 1.0,
            spfValue: 50,
            skinType: .typeI,
            activityLevel: .sedentary,
            isWaterResistant: true
        )
        
        XCTAssertEqual(time, 120)
    }
    
    func testCalculateSafeExposureTime_TypeI() {
        let time = engine.calculateSafeExposureTime(
            uvIndex: 5.0,
            skinType: .typeI
        )
        
        XCTAssertEqual(time, 3)
    }
    
    func testCalculateSafeExposureTime_TypeVI() {
        let time = engine.calculateSafeExposureTime(
            uvIndex: 5.0,
            skinType: .typeVI
        )
        
        XCTAssertEqual(time, 18)
    }
    
    func testGetUVRiskLevel_Low() {
        let risk = engine.getUVRiskLevel(uvIndex: 2.0)
        XCTAssertEqual(risk.level, "Low")
        XCTAssertEqual(risk.color, "green")
    }
    
    func testGetUVRiskLevel_Moderate() {
        let risk = engine.getUVRiskLevel(uvIndex: 4.0)
        XCTAssertEqual(risk.level, "Moderate")
        XCTAssertEqual(risk.color, "yellow")
    }
    
    func testGetUVRiskLevel_High() {
        let risk = engine.getUVRiskLevel(uvIndex: 7.0)
        XCTAssertEqual(risk.level, "High")
        XCTAssertEqual(risk.color, "orange")
    }
    
    func testGetUVRiskLevel_VeryHigh() {
        let risk = engine.getUVRiskLevel(uvIndex: 9.0)
        XCTAssertEqual(risk.level, "Very High")
        XCTAssertEqual(risk.color, "red")
    }
    
    func testGetUVRiskLevel_Extreme() {
        let risk = engine.getUVRiskLevel(uvIndex: 12.0)
        XCTAssertEqual(risk.level, "Extreme")
        XCTAssertEqual(risk.color, "purple")
    }
}
