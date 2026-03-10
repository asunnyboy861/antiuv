import SwiftUI

/// Accessibility color utilities for WCAG compliance
/// Ensures sufficient color contrast for users with visual impairments
struct AccessibilityColors {
    
    /// UV level colors with accessibility-compliant contrast ratios
    enum UVLevel {
        case low
        case moderate
        case high
        case veryHigh
        case extreme
        
        /// Primary color for the UV level
        var color: Color {
            switch self {
            case .low: return Color(red: 0.2, green: 0.6, blue: 0.2)  // Dark green
            case .moderate: return Color(red: 0.8, green: 0.6, blue: 0.0)  // Dark yellow
            case .high: return Color(red: 1.0, green: 0.4, blue: 0.0)  // Dark orange
            case .veryHigh: return Color(red: 0.8, green: 0.0, blue: 0.0)  // Dark red
            case .extreme: return Color(red: 0.5, green: 0.0, blue: 0.5)  // Dark purple
            }
        }
        
        /// Background color with sufficient contrast
        var backgroundColor: Color {
            switch self {
            case .low: return Color(red: 0.9, green: 0.98, blue: 0.9)
            case .moderate: return Color(red: 0.99, green: 0.97, blue: 0.9)
            case .high: return Color(red: 0.99, green: 0.95, blue: 0.9)
            case .veryHigh: return Color(red: 0.99, green: 0.9, blue: 0.9)
            case .extreme: return Color(red: 0.97, green: 0.9, blue: 0.97)
            }
        }
        
        /// Text color for maximum readability
        var textColor: Color {
            switch self {
            case .low, .veryHigh, .extreme: return .white
            case .moderate, .high: return .black
            }
        }
        
        /// Initialize from UV index value
        init(from uvIndex: Double) {
            switch uvIndex {
            case 0..<3: self = .low
            case 3..<6: self = .moderate
            case 6..<8: self = .high
            case 8..<11: self = .veryHigh
            default: self = .extreme
            }
        }
    }
    
    /// Get accessible color for any UV index
    static func color(for uvIndex: Double) -> Color {
        UVLevel(from: uvIndex).color
    }
    
    /// Get accessible background color for any UV index
    static func backgroundColor(for uvIndex: Double) -> Color {
        UVLevel(from: uvIndex).backgroundColor
    }
    
    /// Get accessible text color for any UV index
    static func textColor(for uvIndex: Double) -> Color {
        UVLevel(from: uvIndex).textColor
    }
}
