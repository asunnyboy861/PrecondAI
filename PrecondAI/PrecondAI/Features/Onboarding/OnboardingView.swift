import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var selectedBrand: VehicleBrand?
    @State private var step = 0

    var body: some View {
        TabView(selection: $step) {
            welcomePage().tag(0)
            featurePage().tag(1)
            brandSelectionPage().tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    private func welcomePage() -> some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "car.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.appBlue)
            Text("PrecondAI")
                .font(.system(size: 40, weight: .bold, design: .rounded))
            Text("Smart EV Climate Scheduler")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Weather-aware preconditioning that works when your OEM app doesn't.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
            Button("Get Started") { withAnimation { step = 1 } }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Spacer().frame(height: 40)
        }
    }

    private func featurePage() -> some View {
        VStack(spacing: 24) {
            Spacer()
            FeatureRow(icon: "cloud.sun", title: "Weather-Aware", description: "Adjusts start time based on real-time weather")
            FeatureRow(icon: "battery.75", title: "Battery Safe", description: "Protects your range when unplugged")
            FeatureRow(icon: "clock.badge.checkmark", title: "Reliable Scheduling", description: "Background execution you can count on")
            FeatureRow(icon: "car.2.fill", title: "Multi-Brand", description: "Tesla, Ford, BMW, and more in one app")
            Spacer()
            Button("Next") { withAnimation { step = 2 } }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            Spacer().frame(height: 40)
        }
        .padding(.horizontal, 32)
    }

    private func brandSelectionPage() -> some View {
        VStack(spacing: 24) {
            Text("Select Your EV Brand")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(VehicleBrand.allCases, id: \.self) { brand in
                    BrandButton(brand: brand, isSelected: selectedBrand == brand) {
                        selectedBrand = brand
                    }
                }
            }
            .padding(.horizontal, 24)

            if selectedBrand != nil {
                Button("Continue") {
                    hasCompletedOnboarding = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            Spacer()
        }
        .padding(.top, 40)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.appBlue)
                .frame(width: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct BrandButton: View {
    let brand: VehicleBrand
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(brand.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(isSelected ? Color.appBlue : Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
