import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("temperatureUnit") private var temperatureUnit = "Fahrenheit"
    @AppStorage("defaultTargetTemp") private var defaultTargetTemp = 72.0
    @State private var purchaseManager = PurchaseManager()
    @State private var showPaywall = false

    var body: some View {
        Form {
            Section("Preferences") {
                Picker("Temperature Unit", selection: $temperatureUnit) {
                    Text("Fahrenheit").tag("Fahrenheit")
                    Text("Celsius").tag("Celsius")
                }
                Stepper("Default Target: \(Int(defaultTargetTemp))°F", value: $defaultTargetTemp, in: 55...85, step: 1)
            }

            Section("Subscription") {
                HStack {
                    Text("Status")
                    Spacer()
                    if purchaseManager.isPremium {
                        Label("Premium", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Color.appSuccess)
                    } else {
                        Button("Upgrade to Premium") { showPaywall = true }
                            .foregroundStyle(Color.appBlue)
                    }
                }
                Button("Restore Purchases") {
                    Task { await purchaseManager.restorePurchases() }
                }
            }

            Section("Vehicle") {
                NavigationLink("Add Vehicle", destination: VehicleAuthView())
            }

            Section("Support") {
                NavigationLink("Contact Support", destination: ContactSupportView())
                Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/PrecondAI/privacy.html")!)
                Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/PrecondAI/terms.html")!)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Reset Onboarding", role: .destructive) {
                    hasCompletedOnboarding = false
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showPaywall) {
            PaywallView(purchaseManager: purchaseManager)
        }
        .task {
            await purchaseManager.checkPurchased()
            await purchaseManager.loadProducts()
        }
    }
}
