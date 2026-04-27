import SwiftUI

struct VehicleAuthView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBrand: VehicleBrand = .tesla
    @State private var model = ""
    @State private var year = 2025
    @State private var displayName = ""
    @State private var isAuthenticating = false
    @State private var authError: String?

    var body: some View {
        Form {
            Section("Vehicle Brand") {
                Picker("Brand", selection: $selectedBrand) {
                    ForEach(VehicleBrand.allCases, id: \.self) { brand in
                        Text(brand.rawValue).tag(brand)
                    }
                }
            }

            Section("Vehicle Info") {
                TextField("Model (e.g. Model 3)", text: $model)
                TextField("Display Name (e.g. My Tesla)", text: $displayName)
                Picker("Year", selection: $year) {
                    ForEach((2020...2026).reversed(), id: \.self) { y in
                        Text(String(y)).tag(y)
                    }
                }
            }

            Section {
                Button(action: authenticate) {
                    HStack {
                        Spacer()
                        if isAuthenticating {
                            ProgressView()
                        } else {
                            Text("Connect Vehicle")
                        }
                        Spacer()
                    }
                }
                .disabled(model.isEmpty || displayName.isEmpty || isAuthenticating)
            }

            if let error = authError {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Add Vehicle")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func authenticate() {
        isAuthenticating = true
        authError = nil
        let vehicle = Vehicle(brand: selectedBrand.rawValue, model: model, year: year, displayName: displayName)
        modelContext.insert(vehicle)
        try? modelContext.save()
        isAuthenticating = false
        dismiss()
    }
}
