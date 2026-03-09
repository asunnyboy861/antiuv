import Foundation
import AppIntents

struct GetCurrentUVIndexIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current UV Index"
    static var description: IntentDescription = "Get the current UV index for your location"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let uvDataService = UVDataService()
        
        guard let uvData = await uvDataService.currentUVData else {
            throw IntentError.noData
        }
        
        let message = "Current UV index is \(String(format: "%.1f", uvData.uvIndex)), which is \(uvData.uvLevel)."
        return .result(value: message)
    }
}

struct StartSafetyTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Safety Timer"
    static var description: IntentDescription = "Start a sunscreen reapplication timer"
    static var openAppWhenRun: Bool = true
    
    @Parameter(title: "Duration in minutes", default: 30)
    var duration: Int
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let message = "Starting safety timer for \(duration) minutes"
        return .result(value: message)
    }
}

struct GetSunscreenAdviceIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Sunscreen Advice"
    static var description: IntentDescription = "Get personalized sunscreen advice based on current UV"
    static var openAppWhenRun: Bool = true
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let uvDataService = UVDataService()
        
        guard let uvData = await uvDataService.currentUVData else {
            throw IntentError.noData
        }
        
        let engine = SPFRecommendationEngine()
        let advice = engine.getUVAdvice(uvIndex: uvData.uvIndex, skinType: .typeII)
        
        return .result(value: advice)
    }
}

enum IntentError: LocalizedError {
    case noData
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No UV data available. Please check your location settings."
        case .unauthorized:
            return "App not authorized. Please open the app first."
        }
    }
}

struct AntiUVShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: GetCurrentUVIndexIntent(),
            phrases: [
                "Check UV index with \(.applicationName)",
                "What's the UV index in \(.applicationName)?",
                "Is it sunny outside with \(.applicationName)?"
            ],
            shortTitle: "UV Index",
            systemImageName: "sun.max"
        )
        
        AppShortcut(
            intent: StartSafetyTimerIntent(),
            phrases: [
                "Start sunscreen timer with \(.applicationName)",
                "Remind me to reapply sunscreen with \(.applicationName)",
                "Start UV safety timer with \(.applicationName)"
            ],
            shortTitle: "Safety Timer",
            systemImageName: "timer"
        )
        
        AppShortcut(
            intent: GetSunscreenAdviceIntent(),
            phrases: [
                "Get sunscreen advice with \(.applicationName)",
                "Do I need sunscreen today with \(.applicationName)?",
                "Should I wear sunscreen with \(.applicationName)?"
            ],
            shortTitle: "Sunscreen Advice",
            systemImageName: "drop"
        )
    }
}
