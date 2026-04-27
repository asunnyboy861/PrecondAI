import Foundation
import SwiftData

@Observable
final class VehicleService {
    private let teslaClient: TeslaAPIClient
    private var modelContext: ModelContext?

    init(teslaClient: TeslaAPIClient) {
        self.teslaClient = teslaClient
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchVehicleStatus(vehicle: Vehicle) async throws {
        guard vehicle.brand == VehicleBrand.tesla.rawValue else { return }
        try await teslaClient.wakeUp(vin: vehicle.id)
        let data = try await teslaClient.getVehicleData(vin: vehicle.id)
        guard let state = data.response else { return }
        if let charge = state.chargeState {
            vehicle.batteryLevel = charge.batteryLevel ?? vehicle.batteryLevel
            vehicle.chargingState = charge.chargingState ?? vehicle.chargingState
        }
        if let climate = state.climateState {
            vehicle.insideTemp = climate.insideTemp
            vehicle.outsideTemp = climate.outsideTemp
            vehicle.isClimateOn = climate.isClimateOn ?? vehicle.isClimateOn
        }
        vehicle.lastUpdated = Date()
        try? modelContext?.save()
    }

    func startPreconditioning(vehicle: Vehicle) async throws {
        guard vehicle.brand == VehicleBrand.tesla.rawValue else { return }
        try await teslaClient.startPreconditioning(vin: vehicle.id)
        vehicle.isClimateOn = true
        try? modelContext?.save()
    }

    func stopPreconditioning(vehicle: Vehicle) async throws {
        guard vehicle.brand == VehicleBrand.tesla.rawValue else { return }
        try await teslaClient.stopPreconditioning(vin: vehicle.id)
        vehicle.isClimateOn = false
        try? modelContext?.save()
    }

    func setTemperature(vehicle: Vehicle, driverTemp: Double) async throws {
        guard vehicle.brand == VehicleBrand.tesla.rawValue else { return }
        try await teslaClient.setTemperature(vin: vehicle.id, driverTemp: driverTemp)
    }

    func fahrenheitToCelsius(_ f: Double) -> Double {
        return (f - 32) * 5 / 9
    }
}
