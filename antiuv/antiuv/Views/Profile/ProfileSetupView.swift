import SwiftUI

struct ProfileSetupView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedSkinType: SkinType = .typeII
    @State private var preferredSPF: Int = 30
    @State private var activityLevel: ActivityLevel = .moderateExercise
    
    var onboardingCompleted: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Skin Type")) {
                    Picker("Skin Type", selection: $selectedSkinType) {
                        Text("Type I - Very Fair").tag(SkinType.typeI)
                        Text("Type II - Fair").tag(SkinType.typeII)
                        Text("Type III - Medium").tag(SkinType.typeIII)
                        Text("Type IV - Olive").tag(SkinType.typeIV)
                        Text("Type V - Brown").tag(SkinType.typeV)
                        Text("Type VI - Dark Brown").tag(SkinType.typeVI)
                    }
                    Text("Select your skin type to get personalized UV protection advice.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Sunscreen Preference")) {
                    Stepper("SPF Value: \(preferredSPF)", value: $preferredSPF, in: 15...100, step: 5)
                    Text("Higher SPF provides more protection. Dermatologists recommend SPF 30 or higher.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Activity Level")) {
                    Picker("Activity Level", selection: $activityLevel) {
                        Text("Low (Indoor)").tag(ActivityLevel.sedentary)
                        Text("Moderate (Mixed)").tag(ActivityLevel.moderateExercise)
                        Text("High (Outdoor)").tag(ActivityLevel.intenseExercise)
                    }
                    Text("Your activity level helps us determine how often you need sun protection.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Profile Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveProfile()
                        onboardingCompleted()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func saveProfile() {
        let profile = UserProfile(
            skinType: selectedSkinType,
            preferredSPF: preferredSPF,
            activityLevel: activityLevel,
            isWaterResistant: false,
            notificationEnabled: true,
            morningBriefingEnabled: true,
            uvAlertThreshold: 8.0
        )
        
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: "userProfile")
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }
}

#Preview {
    ProfileSetupView(onboardingCompleted: {})
}
