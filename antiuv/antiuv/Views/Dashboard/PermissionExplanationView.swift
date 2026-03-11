import SwiftUI

struct ValuePropositionCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.orange)
                .frame(width: 50, height: 50)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(description)")
    }
}

struct PermissionExplanationView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                Image(systemName: "location.fill.viewfinder")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                    .accessibilityHidden(true)
                
                Text("Location Access Required")
                    .font(.title)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
                
                Text("To provide accurate UV data, we need your location")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("To provide accurate UV data, we need your location")
            }
            
            VStack(spacing: 20) {
                ValuePropositionCard(
                    icon: "location.fill",
                    title: "Accurate UV Data",
                    description: "We use your location to provide precise UV index data for your area."
                )
                
                ValuePropositionCard(
                    icon: "bell.badge.fill",
                    title: "Smart Alerts",
                    description: "Get notified when UV levels are high in your location."
                )
                
                ValuePropositionCard(
                    icon: "shield.checkerboard",
                    title: "Privacy First",
                    description: "Your location is only used for UV data and never shared."
                )
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                Button(action: {
                    viewModel.requestLocationPermission()
                }) {
                    Text("Enable Location Services")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .accessibilityLabel("Enable Location Services")
                .accessibilityHint("Double tap to grant location permission")
                
                Button(action: {
                    viewModel.useManualLocation()
                }) {
                    Text("Enter Location Manually")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel("Enter Location Manually")
                .accessibilityHint("Double tap to enter your location manually instead")
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    PermissionExplanationView(viewModel: DashboardViewModel())
}
