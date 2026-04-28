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
    @State private var showTeslaAuth = false
    @State private var teslaAuthError: String?
    @StateObject private var teslaOAuthManager = TeslaOAuthManager.shared

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

            if selectedBrand == .tesla {
                Section("Tesla Connection") {
                    if teslaOAuthManager.isAuthenticated {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Tesla Account Connected")
                                .fontWeight(.medium)
                        }
                        
                        Button(action: { Task { await disconnectTesla() } }) {
                            HStack {
                                Image(systemName: "link.badge.minus")
                                    .foregroundStyle(.red)
                                Text("Disconnect Tesla Account")
                                    .foregroundStyle(.red)
                                    .fontWeight(.medium)
                            }
                        }
                    } else {
                        Button(action: { showTeslaAuth = true }) {
                            HStack {
                                Image(systemName: "bolt.car.fill")
                                    .foregroundStyle(Color.appRed)
                                Text("Connect via Tesla Account")
                                    .fontWeight(.medium)
                            }
                        }
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
            
            if let error = teslaAuthError {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
        .navigationTitle("Add Vehicle")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showTeslaAuth) {
            TeslaAuthSheetView()
        }
    }

    private func authenticate() {
        isAuthenticating = true
        authError = nil
        
        let vehicle = Vehicle(brand: selectedBrand.rawValue, model: model, year: year, displayName: displayName)
        vehicle.isTeslaConnected = selectedBrand == .tesla && teslaOAuthManager.isAuthenticated
        vehicle.lastAuthDate = vehicle.isTeslaConnected ? Date() : nil
        
        modelContext.insert(vehicle)
        try? modelContext.save()
        
        isAuthenticating = false
        dismiss()
    }
    
    private func disconnectTesla() async {
        do {
            try teslaOAuthManager.signOut()
        } catch {
            teslaAuthError = error.localizedDescription
        }
    }
}

struct TeslaAuthSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isAuthenticating = false
    @State private var authError: String?
    @StateObject private var teslaOAuthManager = TeslaOAuthManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "bolt.car.circle")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.appRed)
                
                Text("Connect Your Tesla")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("You'll be redirected to Tesla's secure login page to authorize PrecondAI to control your vehicle.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                
                if isAuthenticating {
                    ProgressView("Connecting to Tesla...")
                } else {
                    Button(action: { Task { await startAuth() } }) {
                        Text("Continue with Tesla")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appRed)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                if let error = authError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .navigationTitle("Tesla Authorization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func startAuth() async {
        isAuthenticating = true
        authError = nil
        
        do {
            _ = try await teslaOAuthManager.startAuthFlow()
            dismiss()
        } catch {
            authError = error.localizedDescription
        }
        
        isAuthenticating = false
    }
}
