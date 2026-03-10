import SwiftUI

/// Enhanced onboarding view with better user experience
struct EnhancedOnboardingView: View {
    @State private var currentPage = 0
    @State private var showingProfileSetup = false
    @State private var hasCompletedOnboarding = false
    
    let pages = [
        OnboardingPage(
            icon: "sun.max.fill",
            color: .orange,
            title: "Real-Time UV Monitoring",
            description: "Get accurate UV index data for your exact location with personalized safety recommendations.",
            features: ["Live UV Index", "Location-Based", "Weather Integration"]
        ),
        OnboardingPage(
            icon: "timer",
            color: .blue,
            title: "Smart Safety Timer",
            description: "Personalized reminders to reapply sunscreen based on your skin type and UV conditions.",
            features: ["Custom SPF Settings", "Skin Type Profile", "Activity-Based Alerts"]
        ),
        OnboardingPage(
            icon: "heart.fill",
            color: .red,
            title: "Protect Your Health",
            description: "Reduce skin cancer risk with science-backed sun safety advice tailored to you.",
            features: ["Dermatologist Approved", "Skin Cancer Prevention", "Daily Protection Tips"]
        ),
        OnboardingPage(
            icon: "bell.fill",
            color: .purple,
            title: "Stay Informed",
            description: "Get notified when UV levels are high in your area, so you're always prepared.",
            features: ["Smart Notifications", "Daily Forecasts", "Location Alerts"]
        )
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemGroupedBackground)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            VStack(spacing: 0) {
                ProgressView(value: Double(currentPage + 1), total: Double(pages.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                    .padding(.horizontal)
                
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 450)
                
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.orange : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut(duration: 0.3), value: currentPage)
                    }
                }
                .padding(.vertical, 20)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation {
                            if currentPage < pages.count - 1 {
                                currentPage += 1
                            } else {
                                showingProfileSetup = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: currentPage == pages.count - 1 ? "checkmark.circle.fill" : "arrow.right")
                                .font(.headline)
                            Text(currentPage == pages.count - 1 ? "Set Up Your Profile" : "Continue")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    
                    if currentPage < pages.count - 1 {
                        Button(action: {
                            withAnimation {
                                currentPage = pages.count - 1
                            }
                        }) {
                            Text("Skip to Last")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .sheet(isPresented: $showingProfileSetup) {
            ProfileSetupView(onboardingCompleted: {
                hasCompletedOnboarding = true
            })
        }
    }
}

struct OnboardingPage {
    let icon: String
    let color: Color
    let title: String
    let description: String
    let features: [String]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: page.icon)
                    .font(.system(size: 50))
                    .foregroundColor(page.color)
            }
            .padding(.top, 40)
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            VStack(spacing: 12) {
                ForEach(page.features, id: \.self) { feature in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        
                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 32)
                }
            }
            .padding(.top, 8)
        }
        .padding()
    }
}

#Preview {
    EnhancedOnboardingView()
}
