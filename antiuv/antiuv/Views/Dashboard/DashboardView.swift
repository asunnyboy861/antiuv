import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var timerViewModel = TimerViewModel()
    @State private var showingProfile = false
    @State private var showingTimer = false
    
    private let haptic = HapticFeedbackManager.shared
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.shouldShowPermissionExplanation {
                        PermissionExplanationView(viewModel: viewModel)
                    } else if viewModel.isLoading {
                        LoadingView()
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(message: errorMessage)
                    } else if let uvData = viewModel.uvData {
                        UVIndexCard(uvData: uvData)
                            .onTapGesture {
                                haptic.lightTap()
                            }
                        WeatherCard(uvData: uvData)
                        SafetyTimerCard(
                            viewModel: timerViewModel,
                            uvIndex: uvData.uvIndex,
                            skinType: viewModel.userProfile.skinType,
                            spfValue: viewModel.userProfile.preferredSPF,
                            activityLevel: viewModel.userProfile.activityLevel
                        )
                        AdviceCard(advice: viewModel.uvAdvice)
                    } else {
                        EmptyStateView()
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("UV Monitor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { 
                        haptic.lightTap()
                        showingProfile = true 
                    }) {
                        Image(systemName: "person.circle")
                            .font(.title2)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        haptic.lightTap()
                        Task {
                            await viewModel.refresh()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUVData()
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Fetching UV data...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No UV data available")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

#Preview {
    DashboardView()
}
