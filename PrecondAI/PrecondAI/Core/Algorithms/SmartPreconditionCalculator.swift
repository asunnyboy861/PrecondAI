import Foundation

struct SmartPreconditionCalculator {
    static let minBatteryForUnplugged = 40
    static let minPreconditionMinutes: Double = 5
    static let maxPreconditionMinutes: Double = 45
    static let referenceDelta: Double = 10.0
    static let minutesPerDelta: Double = 5.0

    static func calculateOptimalStartTime(
        departureTime: Date,
        targetTemp: Double,
        outsideTemp: Double,
        isPluggedIn: Bool,
        batteryLevel: Int,
        weatherCondition: WeatherCondition
    ) -> Date? {
        if !isPluggedIn && batteryLevel < minBatteryForUnplugged {
            return nil
        }
        let tempDelta = abs(targetTemp - outsideTemp)
        let baseMinutes = max(minPreconditionMinutes, tempDelta / referenceDelta * minutesPerDelta)
        let weatherMultiplier = weatherCondition.multiplier
        let powerMultiplier = isPluggedIn ? 0.8 : 1.0
        let totalMinutes = baseMinutes * weatherMultiplier * powerMultiplier
        let clampedMinutes = min(max(totalMinutes, minPreconditionMinutes), maxPreconditionMinutes)
        return departureTime.addingTimeInterval(-clampedMinutes * 60)
    }

    static func calculatePreconditionMinutes(
        targetTemp: Double,
        outsideTemp: Double,
        isPluggedIn: Bool,
        batteryLevel: Int,
        weatherCondition: WeatherCondition
    ) -> Int? {
        if !isPluggedIn && batteryLevel < minBatteryForUnplugged {
            return nil
        }
        let tempDelta = abs(targetTemp - outsideTemp)
        let baseMinutes = max(minPreconditionMinutes, tempDelta / referenceDelta * minutesPerDelta)
        let weatherMultiplier = weatherCondition.multiplier
        let powerMultiplier = isPluggedIn ? 0.8 : 1.0
        let totalMinutes = baseMinutes * weatherMultiplier * powerMultiplier
        let clampedMinutes = min(max(totalMinutes, minPreconditionMinutes), maxPreconditionMinutes)
        return Int(clampedMinutes.rounded())
    }

    static func generateWeatherPreview(
        targetTemp: Double,
        forecast: [WeatherData.ForecastItem],
        isPluggedIn: Bool,
        batteryLevel: Int
    ) -> [WeatherPreviewItem] {
        forecast.map { day in
            let avgTemp = (day.tempMin + day.tempMax) / 2
            let minutes = calculatePreconditionMinutes(
                targetTemp: targetTemp,
                outsideTemp: avgTemp,
                isPluggedIn: isPluggedIn,
                batteryLevel: batteryLevel,
                weatherCondition: day.condition
            )
            return WeatherPreviewItem(
                date: day.dateTime,
                outsideTemp: avgTemp,
                condition: day.condition,
                preconditionMinutes: minutes
            )
        }
    }
}

struct WeatherPreviewItem: Identifiable {
    let id = UUID()
    let date: Date
    let outsideTemp: Double
    let condition: WeatherCondition
    let preconditionMinutes: Int?
}
