import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingOnboarding = false
    @State private var showingEducation = false
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("UV Monitor", systemImage: "sun.max")
                }
            
            EducationView()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
        }
    }
    
    private func shouldShowOnboarding() -> Bool {
        let hasProfile = UserDefaults.standard.data(forKey: "userProfile") != nil
        return !hasProfile
    }
}

struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var showingProfileSetup = false
    
    let pages = [
        OnboardingPage(
            icon: "sun.max.fill",
            title: "Track UV Index",
            description: "Get real-time UV index data for your location with accurate forecasts."
        ),
        OnboardingPage(
            icon: "timer",
            title: "Smart Reminders",
            description: "Receive timely notifications to reapply sunscreen based on your skin type."
        ),
        OnboardingPage(
            icon: "heart.fill",
            title: "Protect Your Skin",
            description: "Prevent sunburn and reduce skin cancer risk with personalized advice."
        )
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack(spacing: 16) {
                Button(action: {
                    if currentPage < pages.count - 1 {
                        currentPage += 1
                    } else {
                        showingProfileSetup = true
                    }
                }) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                if currentPage < pages.count - 1 {
                    Button(action: {
                        currentPage = pages.count - 1
                    }) {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingProfileSetup) {
            ProfileSetupView()
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct ProfileSetupView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Welcome!")) {
                    Text("Let's set up your profile to provide personalized UV protection advice.")
                }
                
                Section(header: Text("Skin Type")) {
                    Picker("Select your skin type", selection: Binding(
                        get: { viewModel.userProfile.skinType },
                        set: { viewModel.updateSkinType($0) }
                    )) {
                        ForEach(SkinType.allCases, id: \.self) { skinType in
                            VStack(alignment: .leading) {
                                Text(skinType.displayName)
                                Text(skinType.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .tag(skinType)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section {
                    Button(action: {
                        viewModel.saveProfile()
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Complete Setup")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile Setup")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
