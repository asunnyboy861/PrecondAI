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
                            subtitle: "Save 44% — just $0.05/day",
                            isSelected: selectedPlan == .yearly,
                            badge: "Best Value"
                        ) { selectedPlan = .yearly }

                        PlanCard(
                            title: "Monthly",
                            price: "$2.99/mo",
                            subtitle: "Less than a cup of coffee",
                            isSelected: selectedPlan == .monthly,
                            badge: nil
                        ) { selectedPlan = .monthly }
                    }
                    .padding(.horizontal)

                    FeatureList()

                    Button(action: purchase) {
                        HStack {
                            Spacer()
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Start 7-Day Free Trial")
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

                    Text("Cancel anytime. No charge during trial.")
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

    private func purchase() {
        isPurchasing = true
        Task {
            let product: Product? = selectedPlan == .yearly ? purchaseManager.yearlyProduct : purchaseManager.monthlyProduct
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
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.appBlue : Color.clear, lineWidth: 2)
            )
        }
    }
}

struct FeatureList: View {
    let features = [
        ("cloud.sun", "Weather-Aware Scheduling"),
        ("battery.75", "Battery Safety Protection"),
        ("calendar", "Calendar Integration"),
        ("bell.badge", "Smart Departure Reminders"),
        ("car.2.fill", "Multi-Vehicle Support"),
        ("infinity", "Unlimited Schedules")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(features, id: \.0) { feature in
                HStack(spacing: 12) {
                    Image(systemName: feature.0)
                        .foregroundStyle(Color.appBlue)
                        .frame(width: 24)
                    Text(feature.1)
                        .font(.subheadline)
                }
            }
        }
        .padding()
    }
}
