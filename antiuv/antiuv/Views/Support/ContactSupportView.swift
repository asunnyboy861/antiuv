import SwiftUI

struct ContactSupportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var selectedSubject = "功能建议"
    @State private var customSubject = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var errorMessage: String?
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular
    }
    
    private let subjects = [
        "功能建议",
        "Bug 反馈",
        "使用问题",
        "性能问题",
        "界面优化",
        "其他"
    ]
    
    private var finalSubject: String {
        selectedSubject == "其他" ? customSubject : selectedSubject
    }
    
    private var isValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        email.contains("@") &&
        (!selectedSubject.isEmpty && (selectedSubject != "其他" || !customSubject.isEmpty)) &&
        !message.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Contact Information")) {
                    TextField("Name", text: $name)
                        .textContentType(.name)
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Subject")) {
                    Picker("Subject", selection: $selectedSubject) {
                        ForEach(subjects, id: \.self) { subject in
                            Text(subject).tag(subject)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    if selectedSubject == "其他" {
                        TextField("Custom Subject", text: $customSubject)
                    }
                }
                
                Section(header: Text("Message")) {
                    TextEditor(text: $message)
                        .frame(minHeight: 150)
                        .overlay(
                            Group {
                                if message.isEmpty {
                                    Text("Please describe your feedback or issue in detail...")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 8)
                                        .padding(.leading, 4)
                                }
                            }
                        )
                }
                
                Section {
                    Button(action: submitFeedback) {
                        HStack {
                            Spacer()
                            if isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Submit Feedback")
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                    }
                    .disabled(!isValid || isSubmitting)
                    .foregroundColor(isValid ? .blue : .gray)
                }
                
                if let error = errorMessage {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Contact Support")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .frame(maxWidth: isIPad ? 600 : .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .alert("Feedback Submitted", isPresented: $showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Thank you for your feedback! We'll get back to you soon.")
            }
        }
    }
    
    private func submitFeedback() {
        guard isValid else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                let id = try await FeedbackService.shared.submitFeedbackAsync(
                    name: name,
                    email: email,
                    subject: finalSubject,
                    message: message
                )
                
                await MainActor.run {
                    isSubmitting = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    ContactSupportView()
}
