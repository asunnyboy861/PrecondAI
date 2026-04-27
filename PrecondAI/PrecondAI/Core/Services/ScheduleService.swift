import Foundation
import SwiftData

@Observable
final class ScheduleService {
    var activePrecondition: ActivePrecondition?
    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func createSchedule(
        vehicleId: String,
        departureTime: Date,
        targetTemp: Double,
        daysOfWeek: [Int],
        isWeatherAware: Bool,
        preconditionMinutes: Int,
        notifyBeforeMinutes: Int
    ) -> PreconditionSchedule {
        let optimalStart = departureTime.addingTimeInterval(-Double(preconditionMinutes) * 60)
        let schedule = PreconditionSchedule(
            vehicleId: vehicleId,
            departureTime: departureTime,
            optimalStartTime: optimalStart,
            targetTemp: targetTemp,
            daysOfWeek: daysOfWeek,
            isEnabled: true,
            isWeatherAware: isWeatherAware,
            preconditionMinutes: preconditionMinutes,
            notifyBeforeMinutes: notifyBeforeMinutes
        )
        modelContext?.insert(schedule)
        try? modelContext?.save()
        return schedule
    }

    func updateSchedule(_ schedule: PreconditionSchedule, departureTime: Date? = nil, targetTemp: Double? = nil, daysOfWeek: [Int]? = nil, isWeatherAware: Bool? = nil, preconditionMinutes: Int? = nil, notifyBeforeMinutes: Int? = nil) {
        if let dt = departureTime { schedule.departureTime = dt }
        if let tt = targetTemp { schedule.targetTemp = tt }
        if let dow = daysOfWeek { schedule.daysOfWeek = dow }
        if let wa = isWeatherAware { schedule.isWeatherAware = wa }
        if let pm = preconditionMinutes { schedule.preconditionMinutes = pm }
        if let nb = notifyBeforeMinutes { schedule.notifyBeforeMinutes = nb }
        schedule.optimalStartTime = schedule.departureTime.addingTimeInterval(-Double(schedule.preconditionMinutes) * 60)
        try? modelContext?.save()
    }

    func deleteSchedule(_ schedule: PreconditionSchedule) {
        modelContext?.delete(schedule)
        try? modelContext?.save()
    }

    func toggleSchedule(_ schedule: PreconditionSchedule) {
        schedule.isEnabled.toggle()
        try? modelContext?.save()
    }

    func executePrecondition(schedule: PreconditionSchedule, vehicle: Vehicle, weather: WeatherData?, vehicleService: VehicleService) async throws {
        if !vehicle.isClimateOn {
            try await vehicleService.setTemperature(vehicle: vehicle, driverTemp: vehicleService.fahrenheitToCelsius(schedule.targetTemp))
            try await vehicleService.startPreconditioning(vehicle: vehicle)
        }
        activePrecondition = ActivePrecondition(
            schedule: schedule,
            startedAt: Date(),
            estimatedCompletion: schedule.departureTime
        )
    }

    func stopActivePrecondition(vehicle: Vehicle, vehicleService: VehicleService) async throws {
        if vehicle.isClimateOn {
            try await vehicleService.stopPreconditioning(vehicle: vehicle)
        }
        activePrecondition = nil
    }

    func fetchSchedules() -> [PreconditionSchedule] {
        let descriptor = FetchDescriptor<PreconditionSchedule>(sortBy: [SortDescriptor(\.departureTime)])
        return (try? modelContext?.fetch(descriptor)) ?? []
    }

    func fetchSchedulesForVehicle(vehicleId: String) -> [PreconditionSchedule] {
        let descriptor = FetchDescriptor<PreconditionSchedule>(
            predicate: #Predicate { $0.vehicleId == vehicleId },
            sortBy: [SortDescriptor(\.departureTime)]
        )
        return (try? modelContext?.fetch(descriptor)) ?? []
    }
}
