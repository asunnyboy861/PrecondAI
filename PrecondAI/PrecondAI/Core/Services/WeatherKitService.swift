import Foundation
import CoreLocation
import WeatherKit

@MainActor
final class WeatherKitService: Observable {
    static let shared = WeatherKitService()
    
    private let weatherService = WeatherKit.WeatherService()
    
    func getWeatherForLocation(_ location: CLLocation) async throws -> WeatherData {
        let weather = try await weatherService.weather(for: location)
        let current = weather.currentWeather
        
        return WeatherData(
            current: WeatherData.CurrentWeather(
                temp: current.temperature.value,
                feelsLike: current.apparentTemperature.value,
                humidity: Int(current.humidity * 100),
                windSpeed: current.wind.speed.value,
                condition: current.condition.toAppWeatherCondition(),
                description: current.condition.description
            ),
            forecast: []
        )
    }
    
    func getWeatherForCoordinates(lat: Double, lon: Double) async throws -> WeatherData {
        let location = CLLocation(latitude: lat, longitude: lon)
        return try await getWeatherForLocation(location)
    }
}

extension WeatherKit.WeatherCondition {
    func toAppWeatherCondition() -> WeatherCondition {
        switch self {
        case .clear, .mostlyClear: return .clear
        case .partlyCloudy: return .cloudy
        case .mostlyCloudy, .cloudy: return .cloudy
        case .foggy, .haze, .smoky: return .fog
        case .snow, .heavySnow, .flurries, .blowingSnow: return .snow
        case .drizzle: return .lightRain
        case .rain, .heavyRain: return .heavyRain
        case .thunderstorms: return .heavyRain
        case .windy: return .windy
        case .sleet, .freezingRain: return .ice
        case .hot: return .sunny
        default: return .cloudy
        }
    }
}
