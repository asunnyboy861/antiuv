import XCTest
@testable import antiuv

final class TimerViewModelTests: XCTestCase {
    
    var viewModel: TimerViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = TimerViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testStartTimer() {
        viewModel.startTimer(
            duration: 30,
            uvIndex: 5.0,
            skinType: .typeII,
            spfValue: 50,
            activityLevel: .moderateExercise
        )
        
        XCTAssertTrue(viewModel.isRunning)
        XCTAssertEqual(viewModel.totalTime, 1800)
        XCTAssertEqual(viewModel.timeRemaining, 1800)
    }
    
    func testStopTimer() {
        viewModel.startTimer(
            duration: 30,
            uvIndex: 5.0,
            skinType: .typeII,
            spfValue: 50,
            activityLevel: .moderateExercise
        )
        
        viewModel.stopTimer()
        
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertNotNil(viewModel.timerSession?.endTime)
    }
    
    func testTimerProgress() {
        viewModel.totalTime = 1800
        viewModel.timeRemaining = 900
        
        XCTAssertEqual(viewModel.progress, 0.5)
    }
    
    func testTimeRemainingText() {
        viewModel.timeRemaining = 125
        
        XCTAssertEqual(viewModel.timeRemainingText, "02:05")
    }
    
    func testResetTimer() {
        viewModel.startTimer(
            duration: 30,
            uvIndex: 5.0,
            skinType: .typeII,
            spfValue: 50,
            activityLevel: .moderateExercise
        )
        
        viewModel.resetTimer()
        
        XCTAssertFalse(viewModel.isRunning)
        XCTAssertEqual(viewModel.timeRemaining, 0)
        XCTAssertEqual(viewModel.totalTime, 0)
        XCTAssertNil(viewModel.timerSession)
    }
    
    func testPauseAndResume() {
        viewModel.startTimer(
            duration: 30,
            uvIndex: 5.0,
            skinType: .typeII,
            spfValue: 50,
            activityLevel: .moderateExercise
        )
        
        viewModel.pauseTimer()
        XCTAssertFalse(viewModel.isRunning)
        
        viewModel.resumeTimer()
        XCTAssertTrue(viewModel.isRunning)
    }
}
