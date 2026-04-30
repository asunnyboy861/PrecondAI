import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let purchaseManager: PurchaseManager
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""

    enum PlanType {
        case monthly
        case yearly
        case lifetime
    }

    private let privacyURL = URL(string: "https://asunnyboy861.github.io/PrecondAI/privacy.html")!
    private let termsURL = URL(string: "https://asunnyboy861.github.io/PrecondAI/terms.html")!

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "snowflake.and.flame")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.appBlue)

                    Text("Unlock Smart Preconditioning")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text("Let AI adjust your climate start time based on real-time weather conditions.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    VStack(spacing: 12) {
                        PlanCard(
                            title: "Yearly",
                            price: "$19.99/yr",
                            subtitle: "1 month free, then $19.99/year",
                            isSelected: selectedPlan == .yearly,
                            badge: "Best Value"
                        ) { selectedPlan = .yearly }

                        PlanCard(
                            title: "Monthly",
                            price: "$2.99/mo",
                            subtitle: "7 days free, then $2.99/month",
                            isSelected: selectedPlan == .monthly,
                            badge: nil
                        ) { selectedPlan = .monthly }

                        PlanCard(
                            title: "Lifetime",
                            price: "$49.99",
                            subtitle: "Pay once, use forever",
                            isSelected: selectedPlan == .lifetime,
                            badge: "Most Popular"
                        ) { selectedPlan = .lifetime }
                    }
                    .padding(.horizontal)

                    PaywallFeatureList()

                    Button(action: purchase) {
                        HStack {
                            Spacer()
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(buttonText)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)
                        .background(Color.appBlue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                    .disabled(isPurchasing)

                    Text(subtitleText)
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    Button(action: restorePurchases) {
                        HStack {
                            if isRestoring {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text("Restore Purchases")
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(Color.appBlue)
                    .disabled(isRestoring)

                    HStack(spacing: 4) {
                        Text("By subscribing, you agree to our")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Link("Terms of Use", destination: termsURL)
                            .font(.caption2)
                        Text("and")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Link("Privacy Policy", destination: privacyURL)
                            .font(.caption2)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                }
                .padding(.vertical, 32)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Restore Purchases", isPresented: $showRestoreAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreMessage)
            }
        }
    }

    private var buttonText: String {
        switch selectedPlan {
        case .monthly:
            return "Start Free Trial - $2.99/month After"
        case .yearly:
            return "Start Free Trial - $19.99/year After"
        case .lifetime:
            return "Purchase Lifetime Access - $49.99"
        }
    }

    private var subtitleText: String {
        switch selectedPlan {
        case .monthly:
            return "7-day free trial, then $2.99/month. Cancel anytime in Settings."
        case .yearly:
            return "1-month free trial, then $19.99/year. Cancel anytime in Settings."
        case .lifetime:
            return "One-time purchase of $49.99. No subscription. No recurring charges."
        }
    }

    private func purchase() {
        isPurchasing = true
        Task {
            let product: Product? = switch selectedPlan {
            case .yearly:
                purchaseManager.yearlyProduct
            case .monthly:
                purchaseManager.monthlyProduct
            case .lifetime:
                purchaseManager.lifetimeProduct
            }
            if let product {
                _ = await purchaseManager.purchase(product)
            }
            isPurchasing = false
            if purchaseManager.isPremium {
                dismiss()
            }
        }
    }

    private func restorePurchases() {
        isRestoring = true
        Task {
            await purchaseManager.restorePurchases()
            isRestoring = false
            if purchaseManager.isPremium {
                restoreMessage = "Your purchases have been successfully restored."
            } else {
                restoreMessage = "No previous purchases found. If you believe this is an error, please try again or contact support."
            }
            showRestoreAlert = true
        }
    }
}

struct PlanCard: View {
    let title: String
    let price: String
    let subtitle: String
    let isSelected: Bool
    let badge: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appOrange)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                    Text(price)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.appBlue : .secondary)
            }
            .padding(16)
            .background(isSelected ? Color.appBlue.opacity(0.1) : Color(.systemGray6).opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct PaywallFeatureList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            PaywallFeatureRow(icon: "cloud.sun", text: "Weather-aware scheduling")
            PaywallFeatureRow(icon: "calendar.badge.clock", text: "Unlimited schedules")
            PaywallFeatureRow(icon: "car.2", text: "Up to 3 vehicles")
            PaywallFeatureRow(icon: "battery.100", text: "Battery protection")
        }
        .padding(.horizontal, 32)
    }
}

struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color.appBlue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
