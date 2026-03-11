import SwiftUI

struct SafetyTimerCard: View {
    @ObservedObject var viewModel: TimerViewModel
    let uvIndex: Double
    let skinType: SkinType
    let spfValue: Int
    let activityLevel: ActivityLevel
    
    @State private var showingTimerSetup = false
    
    private let spfEngine = SPFRecommendationEngine()
    
    var reapplyTime: Int {
        spfEngine.calculateReapplyTime(
            uvIndex: uvIndex,
            spfValue: spfValue,
            skinType: skinType,
            activityLevel: activityLevel,
            isWaterResistant: true
        )
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Label("Safety Timer", systemImage: "timer")
                    .font(.headline)
                    .accessibilityLabel("Safety Timer")
                
                Spacer()
                
                Text("Reapply in \(reapplyTime) min")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .accessibilityLabel("Reapply sunscreen in \(reapplyTime) minutes")
            }
            
            if viewModel.isRunning {
                RunningTimerView(viewModel: viewModel)
                    .accessibilityElement(children: .combine)
            } else {
                StartTimerButton(action: { showingTimerSetup = true })
                    .accessibilityLabel("Start safety timer")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $showingTimerSetup) {
            TimerSetupView(
                viewModel: viewModel,
                uvIndex: uvIndex,
                skinType: skinType,
                spfValue: spfValue,
                activityLevel: activityLevel
            )
        }
    }
}

struct RunningTimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                .scaleEffect(y: 2)
            
            Text(viewModel.timeRemainingText)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                Button(action: {
                    if viewModel.isRunning {
                        viewModel.pauseTimer()
                    } else {
                        viewModel.resumeTimer()
                    }
                }) {
                    Label(
                        viewModel.isRunning ? "Pause" : "Resume",
                        systemImage: viewModel.isRunning ? "pause.fill" : "play.fill"
                    )
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    viewModel.resetTimer()
                }) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
    }
}

struct StartTimerButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "timer")
                    .font(.title3)
                Text("Start Safety Timer")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
    }
}

struct TimerSetupView: View {
    @ObservedObject var viewModel: TimerViewModel
    let uvIndex: Double
    let skinType: SkinType
    let spfValue: Int
    let activityLevel: ActivityLevel
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedDuration: Int = 30
    
    private let durations = [15, 30, 45, 60, 90, 120]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Select Timer Duration")
                    .font(.headline)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(durations, id: \.self) { duration in
                        Button(action: {
                            selectedDuration = duration
                        }) {
                            Text("\(duration) min")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(selectedDuration == duration ? Color.orange : Color.gray.opacity(0.2))
                                .foregroundColor(selectedDuration == duration ? .white : .primary)
                                .cornerRadius(8)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Set Timer")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Start") {
                        viewModel.startTimer(
                            duration: selectedDuration,
                            uvIndex: uvIndex,
                            skinType: skinType,
                            spfValue: spfValue,
                            activityLevel: activityLevel
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

#Preview {
    SafetyTimerCard(
        viewModel: TimerViewModel(),
        uvIndex: 7.5,
        skinType: .typeII,
        spfValue: 50,
        activityLevel: .moderateExercise
    )
    .padding()
}
