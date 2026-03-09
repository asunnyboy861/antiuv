import SwiftUI

struct UVIndexCard: View {
    let uvData: UVData
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("UV Index")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(uvData.displayUVIndex)
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(uvColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(uvData.uvLevel)
                        .font(.headline)
                        .foregroundColor(uvColor)
                    
                    Text(lastUpdatedText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            UVLevelIndicator(uvIndex: uvData.uvIndex)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var uvColor: Color {
        switch uvData.uvIndex {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
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
        (level: "Low", max: 2.9, color: Color.green),
        (level: "Moderate", max: 5.9, color: Color.yellow),
        (level: "High", max: 7.9, color: Color.orange),
        (level: "Very High", max: 10.9, color: Color.red),
        (level: "Extreme", max: 15.0, color: Color.purple)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                HStack(spacing: 0) {
                    ForEach(levels, id: \.level) { level in
                        Rectangle()
                            .fill(level.color)
                            .frame(width: geometry.size.width / CGFloat(levels.count) - 2)
                    }
                }
                .frame(height: 8)
                .cornerRadius(4)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 16, height: 16)
                    .shadow(radius: 2)
                    .offset(x: markerPosition(in: geometry.size.width))
            }
        }
        .frame(height: 30)
        
        HStack {
            Text("0")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("11+")
                .font(.caption)
                .foregroundColor(.secondary)
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
        locationName: "Sydney, NSW, Australia",
        timestamp: Date(),
        dataSource: "WeatherKit"
    ))
    .padding()
}
