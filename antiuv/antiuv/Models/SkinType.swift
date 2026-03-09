import Foundation

enum SkinType: Int, CaseIterable, Codable {
    case typeI = 1
    case typeII = 2
    case typeIII = 3
    case typeIV = 4
    case typeV = 5
    case typeVI = 6
    
    var displayName: String {
        switch self {
        case .typeI: return "Type I - Very Fair"
        case .typeII: return "Type II - Fair"
        case .typeIII: return "Type III - Medium"
        case .typeIV: return "Type IV - Olive"
        case .typeV: return "Type V - Brown"
        case .typeVI: return "Type VI - Dark Brown"
        }
    }
    
    var description: String {
        switch self {
        case .typeI: return "Always burns, never tans"
        case .typeII: return "Usually burns, rarely tans"
        case .typeIII: return "Sometimes burns, sometimes tans"
        case .typeIV: return "Rarely burns, often tans"
        case .typeV: return "Very rarely burns, tans easily"
        case .typeVI: return "Never burns, deeply pigmented"
        }
    }
    
    var multiplier: Double {
        switch self {
        case .typeI: return 1.5
        case .typeII: return 1.2
        case .typeIII: return 1.0
        case .typeIV: return 0.8
        case .typeV: return 0.6
        case .typeVI: return 0.5
        }
    }
    
    var baseMED: Int {
        switch self {
        case .typeI: return 15
        case .typeII: return 20
        case .typeIII: return 30
        case .typeIV: return 40
        case .typeV: return 60
        case .typeVI: return 90
        }
    }
}
