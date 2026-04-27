import SwiftUI

struct ContactSupportView: View {
    @State private var topic = "General"
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false

    private let topics = ["General", "Bug Report", "Feature Request", "Subscription Issue", "Vehicle Connection"]

    var body: some View {
        Form {
            Section("Topic") {
                Picker("Topic", selection: $topic) {
                    ForEach(topics, id: \.self) { Text($0) }
                }
            }

            Section("Your Info") {
                TextField("Name (optional)", text: $name)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
            }

            Section("Message") {
                TextEditor(text: $message)
                    .frame(minHeight: 120)
            }

            Section {
                Button(action: submitFeedback) {
                    HStack {
                        Spacer()
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                }
                .disabled(email.isEmpty || message.isEmpty || isSubmitting)
            }
        }
        .navigationTitle("Contact Support")
        .alert("Message Sent", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("We'll get back to you within 24 hours.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text("Failed to send. Please try again.")
        }
    }

    private func dismiss() {
        name = ""
        email = ""
        message = ""
        topic = "General"
    }

    private func submitFeedback() {
        isSubmitting = true
        let feedback = FeedbackRequest(topic: topic, name: name.isEmpty ? nil : name, email: email, message: message)
        guard let url = URL(string: "https://formsubmit.co/ajax/iocompile67692@gmail.com") else {
            isSubmitting = false
            showError = true
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
        guard let body = try? JSONEncoder().encode(feedback) else {
            isSubmitting = false
            showError = true
            return
        }
        request.httpBody = body
        URLSession.shared.dataTask(with: request) { _, response, _ in
            DispatchQueue.main.async {
                isSubmitting = false
                if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                    showSuccess = true
                } else {
                    showError = true
                }
            }
        }.resume()
    }
}

struct FeedbackRequest: Codable {
    let topic: String
    let name: String?
    let email: String
    let message: String
}
