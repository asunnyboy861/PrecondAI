import Foundation

struct WeatherData: Codable {
    let current: CurrentWeather
    let forecast: [ForecastItem]

    struct CurrentWeather: Codable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int
        let windSpeed: Double
        let condition: WeatherCondition
        let description: String
    }

    struct ForecastItem: Codable {
        let dateTime: Date
        let tempMin: Double
        let tempMax: Double
        let condition: WeatherCondition
        let pop: Double
    }
}

enum WeatherCondition: String, Codable, CaseIterable {
    case clear = "Clear"
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case lightRain = "Light Rain"
    case heavyRain = "Heavy Rain"
    case snow = "Snow"
    case ice = "Ice"
    case fog = "Fog"
    case windy = "Windy"

    var iconName: String {
        switch self {
        case .clear: return "moon.stars.fill"
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .lightRain: return "cloud.rain.fill"
        case .heavyRain: return "cloud.heavyrain.fill"
        case .snow: return "snowflake"
        case .ice: return "snowflake"
        case .fog: return "cloud.fog.fill"
        case .windy: return "wind"
        }
    }

    var multiplier: Double {
        switch self {
        case .snow, .ice: return 1.8
        case .heavyRain: return 1.3
        case .lightRain: return 1.1
        case .cloudy: return 1.0
        case .sunny, .clear: return 0.9
        case .fog: return 1.05
        case .windy: return 1.15
        }
    }
}
