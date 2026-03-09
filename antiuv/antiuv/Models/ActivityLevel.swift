import Foundation

enum ActivityLevel: Int, CaseIterable, Codable {
    case sedentary = 0
    case lightExercise = 1
    case moderateExercise = 2
    case intenseExercise = 3
    case swimming = 4
    
    var displayName: String {
        switch self {
        case .sedentary: return "Sedentary (Indoor)"
        case .lightExercise: return "Light Activity"
        case .moderateExercise: return "Moderate Exercise"
        case .intenseExercise: return "Intense Exercise"
        case .swimming: return "Swimming/Water Sports"
        }
    }
    
    var description: String {
        switch self {
        case .sedentary: return "Minimal outdoor activity"
        case .lightExercise: return "Walking, light gardening"
        case .moderateExercise: return "Jogging, cycling"
        case .intenseExercise: return "Running, sports, heavy labor"
        case .swimming: return "Water activities, swimming"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.0
        case .lightExercise: return 0.8
        case .moderateExercise: return 0.6
        case .intenseExercise: return 0.5
        case .swimming: return 0.4
        }
    }
}
