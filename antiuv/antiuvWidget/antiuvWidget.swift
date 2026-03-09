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
        var entries: [SimpleEntry] = []
        
        let currentDate = Date()
        
        // 从 App Group 读取主应用的 UV 数据
        let userDefaults = UserDefaults(suiteName: "group.com.zzsutuo.antiuv")
        let uvIndex = userDefaults?.double(forKey: "uvIndex") ?? 0.0
        let uvLevel = userDefaults?.string(forKey: "uvLevel") ?? "Unknown"
        let location = userDefaults?.string(forKey: "location") ?? "Loading..."
        let lastUpdated = userDefaults?.object(forKey: "lastUpdated") as? Date ?? Date()
        
        let entry = SimpleEntry(
            date: lastUpdated,
            configuration: configuration,
            uvIndex: uvIndex,
            uvLevel: uvLevel,
            location: location
        )
        entries.append(entry)
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let uvIndex: Double
    let uvLevel: String
    let location: String
    
    init(date: Date, configuration: ConfigurationAppIntent, uvIndex: Double = 5.5, uvLevel: String = "Moderate", location: String = "Current Location") {
        self.date = date
        self.configuration = configuration
        self.uvIndex = uvIndex
        self.uvLevel = uvLevel
        self.location = location
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
                    .foregroundColor(uvColor)
                
                Text(entry.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Text(String(format: "%.1f", entry.uvIndex))
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(uvColor)
            
            Text(entry.uvLevel)
                .font(.headline)
                .foregroundColor(uvColor)
            
            Text("Updated \(entry.date, style: .relative) ago")
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
