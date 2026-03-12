import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var timerViewModel = TimerViewModel()
    @State private var showingProfile = false
    @State private var showingTimer = false
    @State private var showingExposureLog = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private let haptic = HapticFeedbackManager.shared
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if isIPad {
                    iPadLayout
                } else {
                    iPhoneLayout
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("UV Monitor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button(action: { 
                            haptic.lightTap()
                            showingExposureLog = true 
                        }) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.title2)
                        }
                        
                        Button(action: { 
                            haptic.lightTap()
                            showingProfile = true 
                        }) {
                            Image(systemName: "person.circle")
                                .font(.title2)
                        }
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
            .sheet(isPresented: $showingExposureLog) {
                ExposureLogView()
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchUVData()
            }
        }
    }
    
    @ViewBuilder
    private var iPhoneLayout: some View {
        VStack(spacing: 16) {
            contentCards
        }
        .padding()
    }
    
    @ViewBuilder
    private var iPadLayout: some View {
        VStack(spacing: 24) {
            if viewModel.shouldShowPermissionExplanation {
                PermissionExplanationView(viewModel: viewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isLoading {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(message: errorMessage)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let uvData = viewModel.uvData {
                VStack(spacing: 24) {
                    HStack(spacing: 20) {
                        UVIndexCard(uvData: uvData)
                            .frame(maxWidth: .infinity)
                            .onTapGesture {
                                haptic.lightTap()
                            }
                        
                        WeatherCard(uvData: uvData)
                            .frame(maxWidth: .infinity)
                        
                        SafetyTimerCard(
                            viewModel: timerViewModel,
                            uvIndex: uvData.uvIndex,
                            skinType: viewModel.userProfile.skinType,
                            spfValue: viewModel.userProfile.preferredSPF,
                            activityLevel: viewModel.userProfile.activityLevel
                        )
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: 1000)
                    
                    AdviceCard(advice: viewModel.uvAdvice)
                        .frame(maxWidth: 1000)
                }
                .frame(maxWidth: .infinity)
            } else {
                EmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var contentCards: some View {
        Group {
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
        .padding()
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
                .frame(maxWidth: 600)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .padding()
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
        .padding()
    }
}

#Preview {
    DashboardView()
}
