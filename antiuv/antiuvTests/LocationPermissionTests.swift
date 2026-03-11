import XCTest
@testable import antiuv

final class LocationPermissionTests: XCTestCase {
    
    func testInfoPlistContainsLocationPermissionKeys() {
        let bundle = Bundle.main
        
        let whenInUseKey = bundle.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String
        XCTAssertNotNil(whenInUseKey, "NSLocationWhenInUseUsageDescription should be present in Info.plist")
        XCTAssertFalse(whenInUseKey!.isEmpty, "NSLocationWhenInUseUsageDescription should not be empty")
        
        let alwaysKey = bundle.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") as? String
        XCTAssertNotNil(alwaysKey, "NSLocationAlwaysAndWhenInUseUsageDescription should be present in Info.plist")
        XCTAssertFalse(alwaysKey!.isEmpty, "NSLocationAlwaysAndWhenInUseUsageDescription should not be empty")
    }
    
    func testPermissionDescriptionIsUserFriendly() {
        let bundle = Bundle.main
        
        let whenInUseKey = bundle.object(forInfoDictionaryKey: "NSLocationWhenInUseUsageDescription") as? String ?? ""
        XCTAssertTrue(whenInUseKey.contains("UV"), "Permission description should mention UV data purpose")
        XCTAssertTrue(whenInUseKey.count > 20, "Permission description should be descriptive")
        
        let alwaysKey = bundle.object(forInfoDictionaryKey: "NSLocationAlwaysAndWhenInUseUsageDescription") as? String ?? ""
        XCTAssertTrue(alwaysKey.contains("UV") || alwaysKey.contains("sunscreen"), "Always permission description should explain background usage")
    }
    
    func testDashboardViewModelHasOpenLocationSettings() {
        let viewModel = DashboardViewModel()
        
        XCTAssertNotNil(viewModel.openLocationSettings, "DashboardViewModel should have openLocationSettings method")
    }
    
    func testDashboardViewModelInitialPermissionState() {
        let viewModel = DashboardViewModel()
        
        XCTAssertNotNil(viewModel.shouldShowPermissionExplanation, "shouldShowPermissionExplanation should be initialized")
        XCTAssertNotNil(viewModel.hasLocationPermission, "hasLocationPermission should be initialized")
    }
}
