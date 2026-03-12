import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let dataService = WidgetDataService()
        
        // Read data from App Group
        let userDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv")
        let uvIndex = userDefaults?.double(forKey: "uvIndex") ?? 0.0
        let uvLevel = userDefaults?.string(forKey: "uvLevel") ?? "Unknown"
        let location = userDefaults?.string(forKey: "location") ?? "Loading..."
        let lastUpdated = userDefaults?.object(forKey: "lastUpdated") as? Date ?? Date()
        
        // Check data freshness using extension methods
        let isStale = dataService.isDataStale()
        let lastUpdatedText = dataService.lastUpdatedText()
        
        let entry = SimpleEntry(
            date: lastUpdated,
            configuration: configuration,
            uvIndex: uvIndex,
            uvLevel: uvLevel,
            location: location,
            isStale: isStale,
            lastUpdatedText: lastUpdatedText
        )
        
        // Set refresh strategy: refresh every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let uvIndex: Double
    let uvLevel: String
    let location: String
    let isStale: Bool
    let lastUpdatedText: String
    
    init(date: Date, configuration: ConfigurationAppIntent, uvIndex: Double = 5.5, uvLevel: String = "Moderate", location: String = "Current Location", isStale: Bool = false, lastUpdatedText: String = "just now") {
        self.date = date
        self.configuration = configuration
        self.uvIndex = uvIndex
        self.uvLevel = uvLevel
        self.location = location
        self.isStale = isStale
        self.lastUpdatedText = lastUpdatedText
    }
}

struct antiuvWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var uvColor: Color {
        switch entry.uvIndex {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
    }
    
    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            antiuvWidgetMedium(entry: entry)
        case .systemLarge:
            antiuvWidgetLarge(entry: entry)
        default:
            smallWidget
        }
    }
    
    var smallWidget: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.title2)
                    .foregroundColor(entry.isStale ? .gray : uvColor)
                
                Text(entry.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if entry.isStale {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Data may be outdated")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                Text(String(format: "%.1f", entry.uvIndex))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(uvColor)
                
                Text(entry.uvLevel)
                    .font(.headline)
                    .foregroundColor(uvColor)
            }
            
            Text("Updated \(entry.lastUpdatedText)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct antiuvWidget: Widget {
    let kind: String = "antiuvWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            antiuvWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct antiuvWidgetMedium: View {
    var entry: Provider.Entry
    
    var uvColor: Color {
        switch entry.uvIndex {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "sun.max.fill")
                        .foregroundColor(entry.isStale ? .gray : uvColor)
                    Text(entry.location)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if entry.isStale {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        Text("Data may be outdated")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(String(format: "%.1f", entry.uvIndex))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(uvColor)
                    
                    Text(entry.uvLevel)
                        .font(.subheadline)
                        .foregroundColor(uvColor)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                Image(systemName: "shield.fill")
                    .font(.title)
                    .foregroundColor(entry.isStale ? .gray : uvColor)
                
                Text("Updated \(entry.lastUpdatedText)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

struct antiuvWidgetLarge: View {
    var entry: Provider.Entry
    
    var uvColor: Color {
        switch entry.uvIndex {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
    }
    
    var safeTime: String {
        let baseTime = max(15, Int(120 / max(entry.uvIndex, 1.0)))
        return "\(baseTime) min"
    }
    
    var protectionAdvice: String {
        switch entry.uvIndex {
        case 0..<3: return "No protection needed"
        case 3..<6: return "Seek shade midday"
        case 6..<8: return "Protection required"
        case 8..<11: return "Extra protection needed"
        default: return "Avoid sun exposure"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .font(.title2)
                    .foregroundColor(entry.isStale ? .gray : uvColor)
                
                Text(entry.location)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Spacer()
                
                Text("Updated \(entry.lastUpdatedText)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if entry.isStale {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text("Data may be outdated")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            } else {
                HStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(String(format: "%.1f", entry.uvIndex))
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(uvColor)
                        
                        Text(entry.uvLevel)
                            .font(.headline)
                            .foregroundColor(uvColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.blue)
                            Text("Safe time: \(safeTime)")
                                .font(.subheadline)
                        }
                        
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundColor(.green)
                            Text(protectionAdvice)
                                .font(.caption)
                                .lineLimit(2)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    antiuvWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, uvIndex: 5.5, uvLevel: "Moderate", location: "Sydney")
    SimpleEntry(date: .now, configuration: .starEyes, uvIndex: 8.2, uvLevel: "Very High", location: "Gold Coast")
}

#Preview(as: .systemMedium) {
    antiuvWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, uvIndex: 5.5, uvLevel: "Moderate", location: "Sydney")
    SimpleEntry(date: .now, configuration: .starEyes, uvIndex: 8.2, uvLevel: "Very High", location: "Gold Coast")
}

#Preview(as: .systemLarge) {
    antiuvWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, uvIndex: 5.5, uvLevel: "Moderate", location: "Sydney")
    SimpleEntry(date: .now, configuration: .starEyes, uvIndex: 8.2, uvLevel: "Very High", location: "Gold Coast")
}
