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
        .supportedFamilies([.systemSmall])
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
