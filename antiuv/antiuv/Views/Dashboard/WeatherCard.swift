import SwiftUI

struct WeatherCard: View {
    let uvData: UVData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Weather Conditions", systemImage: "cloud.sun")
                    .font(.headline)
                
                Spacer()
                
                Text(uvData.locationName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 20) {
                WeatherInfoItem(
                    icon: "thermometer.sun",
                    label: "Temperature",
                    value: uvData.displayTemperature
                )
                
                Divider()
                    .frame(height: 40)
                
                WeatherInfoItem(
                    icon: "cloud",
                    label: "Cloud Cover",
                    value: uvData.displayCloudCover
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
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
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeatherCard(uvData: UVData(
        uvIndex: 7.5,
        temperature: 25.0,
        cloudCover: 0.3,
        locationName: "Sydney, NSW, Australia",
        timestamp: Date(),
        dataSource: "WeatherKit"
    ))
    .padding()
}
