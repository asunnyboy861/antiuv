import Foundation
import Combine

class TimerViewModel: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var timeRemaining: Int = 0
    @Published var totalTime: Int = 0
    @Published var timerSession: ExposureSession?
    
    private var timer: Timer?
    private let spfEngine = SPFRecommendationEngine()
    
    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return Double(timeRemaining) / Double(totalTime)
    }
    
    var timeRemainingText: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var totalTimeText: String {
        "\(totalTime / 60) min"
    }
    
    func startTimer(
        duration: Int,
        uvIndex: Double,
        skinType: SkinType,
        spfValue: Int,
        activityLevel: ActivityLevel
    ) {
        stopTimer()
        
        totalTime = duration * 60
        timeRemaining = totalTime
        
        timerSession = ExposureSession(
            uvIndex: uvIndex,
            skinType: skinType,
            spfValue: spfValue,
            activityLevel: activityLevel,
            plannedDuration: duration
        )
        
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        
        if let session = timerSession {
            timerSession = ExposureSession(
                id: session.id,
                startTime: session.startTime,
                endTime: Date(),
                uvIndex: session.uvIndex,
                skinType: session.skinType,
                spfValue: session.spfValue,
                activityLevel: session.activityLevel,
                plannedDuration: session.plannedDuration,
                actualDuration: totalTime - timeRemaining,
                completed: false
            )
        }
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = 0
        totalTime = 0
        timerSession = nil
    }
    
    private func timerCompleted() {
        stopTimer()
        
        if let session = timerSession {
            timerSession = ExposureSession(
                id: session.id,
                startTime: session.startTime,
                endTime: Date(),
                uvIndex: session.uvIndex,
                skinType: session.skinType,
                spfValue: session.spfValue,
                activityLevel: session.activityLevel,
                plannedDuration: session.plannedDuration,
                actualDuration: totalTime,
                completed: true
            )
        }
        
        NotificationCenter.default.post(
            name: .timerCompleted,
            object: nil,
            userInfo: ["session": timerSession]
        )
    }
    
    func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func resumeTimer() {
        guard !isRunning && timeRemaining > 0 else { return }
        
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.timerCompleted()
            }
        }
    }
}

extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}
