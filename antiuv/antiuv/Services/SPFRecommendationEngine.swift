import Foundation

class SPFRecommendationEngine {
    
    func calculateReapplyTime(
        uvIndex: Double,
        spfValue: Int,
        skinType: SkinType,
        activityLevel: ActivityLevel,
        isWaterResistant: Bool
    ) -> Int {
        let baseTime = Double(spfValue) * 10.0 / max(uvIndex, 1.0)
        let skinAdjustedTime = baseTime * skinType.multiplier
        let activityAdjustedTime = skinAdjustedTime * activityLevel.multiplier
        
        let waterAdjustedTime: Double
        if !isWaterResistant && (activityLevel == .swimming || activityLevel == .intenseExercise) {
            waterAdjustedTime = activityAdjustedTime * 0.5
        } else {
            waterAdjustedTime = activityAdjustedTime
        }
        
        let finalTime = max(15, min(120, Int(waterAdjustedTime.rounded())))
        return finalTime
    }
    
    func calculateSafeExposureTime(
        uvIndex: Double,
        skinType: SkinType
    ) -> Int {
        let med = Double(skinType.baseMED)
        let safeTime = med / max(uvIndex, 1.0)
        return max(5, Int(safeTime.rounded()))
    }
    
    func getUVRiskLevel(uvIndex: Double) -> (level: String, color: String, advice: String) {
        switch uvIndex {
        case 0..<3:
            return ("Low", "green", "No protection needed. Safe to be outside.")
        case 3..<6:
            return ("Moderate", "yellow", "Seek shade during midday hours. Wear sunscreen.")
        case 6..<8:
            return ("High", "orange", "Protection required. Reduce sun exposure 10am-4pm.")
        case 8..<11:
            return ("Very High", "red", "Extra protection needed. Avoid sun during midday.")
        default:
            return ("Extreme", "purple", "Take all precautions. Avoid being outside.")
        }
    }
    
    func getUVAdvice(uvIndex: Double, skinType: SkinType) -> String {
        let riskLevel = getUVRiskLevel(uvIndex: uvIndex)
        let safeTime = calculateSafeExposureTime(uvIndex: uvIndex, skinType: skinType)
        
        switch riskLevel.level {
        case "Low":
            return "Enjoy being outside! With your skin type, you can safely stay in the sun for about \(safeTime) minutes without sunscreen."
        case "Moderate":
            return "Take precautions! Wear sunscreen SPF 30+ and seek shade during midday hours. Safe exposure: ~\(safeTime) minutes."
        case "High":
            return "Protection required! Wear protective clothing, hat, sunglasses, and SPF 50+ sunscreen. Limit sun exposure."
        case "Very High":
            return "Extra protection needed! Avoid sun exposure between 10am-4pm. If outside, use SPF 50+ and reapply every 60 minutes."
        case "Extreme":
            return "⚠️ Extreme danger! Avoid being outside. Unprotected skin can burn in less than \(safeTime) minutes."
        default:
            return riskLevel.advice
        }
    }
}
