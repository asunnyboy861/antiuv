import SwiftUI

struct UVIndexCard: View {
    let uvData: UVData
    
    private var uvLevel: AccessibilityColors.UVLevel {
        AccessibilityColors.UVLevel(from: uvData.uvIndex)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("UV Index")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("UV Index")
                    
                    Text(uvData.displayUVIndex)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(uvLevel.textColor)
                        .accessibilityLabel("UV Index value: \(uvData.uvIndex, specifier: "%.1f")")
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(uvData.uvLevel)
                        .font(.headline)
                        .foregroundColor(uvLevel.textColor)
                        .accessibilityLabel("Risk level: \(uvData.uvLevel)")
                    
                    Text(lastUpdatedText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Last updated: \(lastUpdatedText)")
                }
            }
            
            UVLevelIndicator(uvIndex: uvData.uvIndex)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(uvLevel.backgroundColor)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
    
    private var uvColor: Color {
        AccessibilityColors.color(for: uvData.uvIndex)
    }
    
    private var lastUpdatedText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "Updated \(formatter.localizedString(for: uvData.timestamp, relativeTo: Date()))"
    }
}

struct UVLevelIndicator: View {
    let uvIndex: Double
    
    private let levels = [
        (level: "Low", max: 2.9, color: AccessibilityColors.UVLevel.low.color),
        (level: "Moderate", max: 5.9, color: AccessibilityColors.UVLevel.moderate.color),
        (level: "High", max: 7.9, color: AccessibilityColors.UVLevel.high.color),
        (level: "Very High", max: 10.9, color: AccessibilityColors.UVLevel.veryHigh.color),
        (level: "Extreme", max: 15.0, color: AccessibilityColors.UVLevel.extreme.color)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                    .accessibilityHidden(true)
                
                HStack(spacing: 0) {
                    ForEach(levels, id: \.level) { level in
                        Rectangle()
                            .fill(level.color)
                            .frame(width: geometry.size.width / CGFloat(levels.count) - 2)
                    }
                }
                .frame(height: 8)
                .cornerRadius(4)
                .accessibilityHidden(true)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .shadow(radius: 2)
                    .offset(x: markerPosition(in: geometry.size.width))
                    .accessibilityHidden(true)
            }
        }
        .frame(height: 30)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("UV level indicator")
        .accessibilityValue("Current UV index: \(uvIndex, specifier: "%.1f") on a scale from 0 to 11+")
        
        HStack {
            Text("0")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
            
            Spacer()
            
            Text("11+")
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
    }
    
    private func markerPosition(in width: CGFloat) -> CGFloat {
        let segmentWidth = width / CGFloat(levels.count)
        let position: CGFloat
        
        switch uvIndex {
        case 0..<3:
            position = CGFloat(uvIndex / 2.9) * segmentWidth
        case 3..<6:
            position = segmentWidth + CGFloat((uvIndex - 3) / 2.9) * segmentWidth
        case 6..<8:
            position = 2 * segmentWidth + CGFloat((uvIndex - 6) / 1.9) * segmentWidth
        case 8..<11:
            position = 3 * segmentWidth + CGFloat((uvIndex - 8) / 2.9) * segmentWidth
        default:
            position = 4 * segmentWidth + CGFloat((uvIndex - 11) / 4) * segmentWidth
        }
        
        return min(position, width - 8)
    }
}

#Preview {
    UVIndexCard(uvData: UVData(
        uvIndex: 7.5,
        temperature: 25.0,
        cloudCover: 0.3,
        locationName: "Los Angeles, CA, USA",
        timestamp: Date(),
        dataSource: "WeatherKit",
        weatherCondition: .partlyCloudy,
        humidity: 45.0,
        windSpeed: 12.0
    ))
    .padding()
}
