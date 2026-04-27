import Foundation
import SwiftData

@Model
final class PreconditionSchedule {
    @Attribute(.unique) var id: UUID
    var vehicleId: String
    var departureTime: Date
    var optimalStartTime: Date
    var targetTemp: Double
    var daysOfWeek: [Int]
    var isEnabled: Bool
    var isWeatherAware: Bool
    var preconditionMinutes: Int
    var notifyBeforeMinutes: Int
    var createdAt: Date
    var lastExecutedAt: Date?

    init(
        vehicleId: String,
        departureTime: Date,
        optimalStartTime: Date,
        targetTemp: Double = 72.0,
        daysOfWeek: [Int] = [2, 3, 4, 5, 6],
        isEnabled: Bool = true,
        isWeatherAware: Bool = true,
        preconditionMinutes: Int = 20,
        notifyBeforeMinutes: Int = 15
    ) {
        self.id = UUID()
        self.vehicleId = vehicleId
        self.departureTime = departureTime
        self.optimalStartTime = optimalStartTime
        self.targetTemp = targetTemp
        self.daysOfWeek = daysOfWeek
        self.isEnabled = isEnabled
        self.isWeatherAware = isWeatherAware
        self.preconditionMinutes = preconditionMinutes
        self.notifyBeforeMinutes = notifyBeforeMinutes
        self.createdAt = Date()
    }
}
