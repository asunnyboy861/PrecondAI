import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    let purchaseManager: PurchaseManager
    @State private var selectedPlan: PlanType = .yearly
    @State private var isPurchasing = false

    enum PlanType {
        case monthly
        case yearly
        case lifetime
    }

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
                            subtitle: "Save 44% — 1 month free trial",
                            isSelected: selectedPlan == .yearly,
                            badge: "Best Value"
                        ) { selectedPlan = .yearly }

                        PlanCard(
                            title: "Monthly",
                            price: "$2.99/mo",
                            subtitle: "7 days free trial",
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

                    Button("Restore Purchases") {
                        Task { await purchaseManager.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundStyle(Color.appBlue)
                }
                .padding(.vertical, 32)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var buttonText: String {
        switch selectedPlan {
        case .monthly:
            return "Start 7-Day Free Trial"
        case .yearly:
            return "Start 1-Month Free Trial"
        case .lifetime:
            return "Purchase Lifetime Access"
        }
    }

    private var subtitleText: String {
        switch selectedPlan {
        case .monthly:
            return "Cancel anytime. No charge during trial."
        case .yearly:
            return "Cancel anytime. No charge during 1-month trial."
        case .lifetime:
            return "One-time purchase. No subscription needed."
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
