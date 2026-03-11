import SwiftUI

struct WeatherCard: View {
    let uvData: UVData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Weather Conditions", systemImage: uvData.weatherCondition.systemImage)
                    .font(.headline)
                    .foregroundColor(uvData.weatherCondition.color)
                    .accessibilityLabel("Weather Conditions: \(uvData.weatherCondition.displayName)")
                
                Spacer()
                
                Text(uvData.locationName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .accessibilityLabel("Location: \(uvData.locationName)")
            }
            
            HStack(spacing: 16) {
                WeatherInfoItem(
                    icon: "thermometer.sun",
                    label: "Temperature",
                    value: uvData.displayTemperatureLocalized
                )
                .accessibilityElement(children: .combine)
                
                Divider()
                    .frame(height: 40)
                    .accessibilityHidden(true)
                
                WeatherInfoItem(
                    icon: "drop.fill",
                    label: "Humidity",
                    value: uvData.displayHumidity
                )
                .accessibilityElement(children: .combine)
                
                Divider()
                    .frame(height: 40)
                    .accessibilityHidden(true)
                
                WeatherInfoItem(
                    icon: "wind",
                    label: "Wind",
                    value: uvData.displayWindSpeed
                )
                .accessibilityElement(children: .combine)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Weather conditions: \(uvData.weatherCondition.displayName), temperature \(uvData.displayTemperatureLocalized), humidity \(uvData.displayHumidity), wind \(uvData.displayWindSpeed)")
    }
}

struct WeatherInfoItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .accessibilityHidden(true)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .accessibilityLabel("\(label): \(value)")
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeatherCard(uvData: UVData(
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
