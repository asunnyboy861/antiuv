import SwiftUI

struct ExposureLogView: View {
    @State private var sessions: [ExposureSession] = []
    @State private var showingDeleteConfirmation = false
    
    private let coreDataStack = CoreDataStack.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if sessions.isEmpty {
                    EmptyLogView()
                } else {
                    SessionListView(sessions: sessions, onDelete: deleteSession)
                }
            }
            .navigationTitle("Exposure History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !sessions.isEmpty {
                        Menu {
                            Button(role: .destructive, action: {
                                showingDeleteConfirmation = true
                            }) {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .confirmationDialog(
                "Clear All History?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Clear All", role: .destructive) {
                    deleteAllSessions()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone.")
            }
        }
        .onAppear {
            loadSessions()
        }
    }
    
    private func loadSessions() {
        sessions = coreDataStack.fetchAllSessions()
    }
    
    private func deleteSession(at offsets: IndexSet) {
        offsets.forEach { index in
            coreDataStack.deleteSession(id: sessions[index].id)
        }
        sessions.remove(atOffsets: offsets)
    }
    
    private func deleteAllSessions() {
        coreDataStack.deleteAllSessions()
        sessions.removeAll()
    }
}

struct SessionListView: View {
    let sessions: [ExposureSession]
    let onDelete: (IndexSet) -> Void
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    var body: some View {
        List {
            ForEach(groupedSessions.keys.sorted().reversed(), id: \.self) { date in
                Section(header: Text(formatDate(date))) {
                    ForEach(groupedSessions[date] ?? []) { session in
                        SessionRowView(session: session)
                    }
                    .onDelete { offsets in
                        let indicesToDelete = offsets.map { offset in
                            sessions.firstIndex(where: { $0.id == groupedSessions[date]![offset].id })!
                        }
                        onDelete(IndexSet(indicesToDelete))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .frame(maxWidth: isIPad ? 800 : .infinity)
    }
    
    private var groupedSessions: [Date: [ExposureSession]] {
        Dictionary(grouping: sessions) { session in
            Calendar.current.startOfDay(for: session.startTime)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct SessionRowView: View {
    let session: ExposureSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundColor(uvColor(for: session.uvIndex))
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("UV \(Int(session.uvIndex))")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(formatTime(session.startTime))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("\(session.durationText)", systemImage: "timer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label("SPF \(session.spfValue)", systemImage: "drop.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if session.isCompleted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 4)
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
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct EmptyLogView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sun.min")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Exposure History")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start a safety timer to track your sun exposure sessions.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ExposureLogView()
}
