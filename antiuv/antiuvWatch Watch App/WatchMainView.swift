import SwiftUI

struct WatchMainView: View {
    @StateObject private var viewModel = WatchUVViewModel()
    
    var body: some View {
        TabView {
            WatchUVIndexView(viewModel: viewModel)
            
            WatchTimerView(viewModel: viewModel)
            
            WatchSettingsView()
        }
        .tabViewStyle(.verticalPage)
    }
}

struct WatchUVIndexView: View {
    @ObservedObject var viewModel: WatchUVViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(0.8)
            } else if let error = viewModel.error {
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                }
            } else if let uvData = viewModel.uvData {
                Image(systemName: "sun.max.fill")
                    .font(.title)
                    .foregroundColor(uvColor(for: uvData.uvIndex))
                
                Text(String(format: "%.1f", uvData.uvIndex))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(uvColor(for: uvData.uvIndex))
                
                Text(uvData.uvLevel)
                    .font(.caption)
                    .foregroundColor(uvColor(for: uvData.uvIndex))
                
                Text(uvData.locationName)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .onAppear {
            viewModel.fetchUVData()
        }
    }
    
    private func uvColor(for index: Double) -> Color {
        switch index {
        case 0..<3: return .green
        case 3..<6: return .yellow
        case 6..<8: return .orange
        case 8..<11: return .red
        default: return .purple
        }
    }
}

struct WatchTimerView: View {
    @ObservedObject var viewModel: WatchUVViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            if viewModel.isTimerRunning {
                VStack(spacing: 4) {
                    Text(viewModel.timerText)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    
                    ProgressView(value: viewModel.timerProgress)
                        .tint(.orange)
                    
                    HStack(spacing: 12) {
                        Button(action: {
                            viewModel.pauseTimer()
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                        
                        Button(action: {
                            viewModel.stopTimer()
                        }) {
                            Image(systemName: "stop.fill")
                                .font(.caption)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            } else {
                Image(systemName: "timer")
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text("Safety Timer")
                    .font(.caption)
                
                Button("Start") {
                    viewModel.startQuickTimer()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

struct WatchSettingsView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "gear")
                .font(.title)
                .foregroundColor(.gray)
            
            Text("Settings")
                .font(.caption)
            
            Text("Open iPhone app to configure")
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    WatchMainView()
}
