import Foundation

struct ExposureSession: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date?
    let uvIndex: Double
    let skinType: SkinType
    let spfValue: Int
    let activityLevel: ActivityLevel
    let plannedDuration: Int
    let actualDuration: Int?
    let completed: Bool
    
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        uvIndex: Double,
        skinType: SkinType,
        spfValue: Int,
        activityLevel: ActivityLevel,
        plannedDuration: Int,
        actualDuration: Int? = nil,
        completed: Bool = false
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.uvIndex = uvIndex
        self.skinType = skinType
        self.spfValue = spfValue
        self.activityLevel = activityLevel
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.completed = completed
    }
    
    var durationText: String {
        if let actual = actualDuration {
            return "\(actual) min"
        } else {
            return "\(plannedDuration) min planned"
        }
    }
    
    var isCompleted: Bool {
        completed || endTime != nil
    }
}
