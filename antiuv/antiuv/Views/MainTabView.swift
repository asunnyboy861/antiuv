import SwiftUI

/// Main tab view for the application
struct MainTabView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @State private var selectedTab = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        Group {
            if isIPad {
                iPadTabView
            } else {
                iPhoneTabView
            }
        }
        .accentColor(.orange)
    }
    
    private var iPhoneTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("UV Monitor", systemImage: "sun.max")
                }
                .tag(0)
            
            EducationView()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
    }
    
    private var iPadTabView: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("UV Monitor", systemImage: "sun.max")
                }
                .tag(0)
            
            EducationView()
                .tabItem {
                    Label("Learn", systemImage: "book")
                }
                .tag(1)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
}
