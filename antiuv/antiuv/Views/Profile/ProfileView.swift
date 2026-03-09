import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Skin Profile")) {
                    Picker("Skin Type", selection: Binding(
                        get: { viewModel.userProfile.skinType },
                        set: { viewModel.updateSkinType($0) }
                    )) {
                        ForEach(SkinType.allCases, id: \.self) { skinType in
                            Text(skinType.displayName).tag(skinType)
                        }
                    }
                    
                    Picker("Preferred SPF", selection: Binding(
                        get: { viewModel.userProfile.preferredSPF },
                        set: { viewModel.updateSPF($0) }
                    )) {
                        Text("SPF 15").tag(15)
                        Text("SPF 30").tag(30)
                        Text("SPF 50").tag(50)
                        Text("SPF 50+").tag(50)
                    }
                    
                    Picker("Activity Level", selection: Binding(
                        get: { viewModel.userProfile.activityLevel },
                        set: { viewModel.updateActivityLevel($0) }
                    )) {
                        ForEach(ActivityLevel.allCases, id: \.self) { activityLevel in
                            Text(activityLevel.displayName).tag(activityLevel)
                        }
                    }
                }
                
                Section(header: Text("Sunscreen Settings")) {
                    Toggle("Water Resistant", isOn: Binding(
                        get: { viewModel.userProfile.isWaterResistant },
                        set: { viewModel.updateWaterResistant($0) }
                    ))
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Enable Reminders", isOn: Binding(
                        get: { viewModel.userProfile.notificationEnabled },
                        set: { viewModel.updateNotificationEnabled($0) }
                    ))
                    
                    Toggle("Morning Briefing (8 AM)", isOn: Binding(
                        get: { viewModel.userProfile.morningBriefingEnabled },
                        set: { viewModel.updateMorningBriefingEnabled($0) }
                    ))
                    
                    Stepper("UV Alert Threshold: \(viewModel.userProfile.uvAlertThreshold, specifier: "%.0f")",
                            value: Binding(
                                get: { viewModel.userProfile.uvAlertThreshold },
                                set: { viewModel.updateUVAlertThreshold($0) }
                            ),
                            in: 6...11,
                            step: 1)
                }
                
                Section {
                    Button(action: {
                        viewModel.saveProfile()
                        dismiss()
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Settings")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .foregroundColor(viewModel.isSaved ? .gray : .blue)
                    .disabled(!viewModel.isValid || viewModel.isSaved)
                }
            }
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
