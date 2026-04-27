import Foundation

actor WeatherAPIClient {
    private let apiKey: String
    private let baseURL = "https://api.openweathermap.org/data/3.0"
    private var cache: [String: (data: WeatherData, timestamp: Date)] = [:]
    private let cacheDuration: TimeInterval = 1800

    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func getCurrentWeather(lat: Double, lon: Double) async throws -> WeatherData {
        let cacheKey = "\(lat),\(lon)"
        if let cached = cache[cacheKey], Date().timeIntervalSince(cached.timestamp) < cacheDuration {
            return cached.data
        }
        let urlString = "\(baseURL)/onecall?lat=\(lat)&lon=\(lon)&units=imperial&appid=\(apiKey)"
        guard let url = URL(string: urlString) else { throw APIError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        let decoded = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
        let weatherData = mapToWeatherData(decoded)
        cache[cacheKey] = (data: weatherData, timestamp: Date())
        return weatherData
    }

    private func mapToWeatherData(_ response: OpenWeatherResponse) -> WeatherData {
        let current = WeatherData.CurrentWeather(
            temp: response.current.temp,
            feelsLike: response.current.feelsLike,
            humidity: response.current.humidity,
            windSpeed: response.current.windSpeed,
            condition: mapCondition(response.current.weather.first?.main ?? ""),
            description: response.current.weather.first?.description ?? ""
        )
        let forecast = response.daily.prefix(7).map { day in
            WeatherData.ForecastItem(
                dateTime: Date(timeIntervalSince1970: TimeInterval(day.dt)),
                tempMin: day.temp.min,
                tempMax: day.temp.max,
                condition: mapCondition(day.weather.first?.main ?? ""),
                pop: day.pop
            )
        }
        return WeatherData(current: current, forecast: forecast)
    }

    private func mapCondition(_ main: String) -> WeatherCondition {
        switch main.lowercased() {
        case "clear": return .clear
        case "clouds": return .cloudy
        case "rain": return .lightRain
        case "drizzle": return .lightRain
        case "thunderstorm": return .heavyRain
        case "snow": return .snow
        case "mist", "fog", "haze": return .fog
        default: return .cloudy
        }
    }
}

struct OpenWeatherResponse: Codable {
    let current: OpenWeatherCurrent
    let daily: [OpenWeatherDaily]

    struct OpenWeatherCurrent: Codable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int
        let windSpeed: Double
        let weather: [OpenWeatherDesc]

        enum CodingKeys: String, CodingKey {
            case temp, humidity, weather
            case feelsLike = "feels_like"
            case windSpeed = "wind_speed"
        }
    }

    struct OpenWeatherDaily: Codable {
        let dt: Int
        let temp: OpenWeatherTemp
        let weather: [OpenWeatherDesc]
        let pop: Double
    }

    struct OpenWeatherTemp: Codable {
        let min: Double
        let max: Double
    }

    struct OpenWeatherDesc: Codable {
        let main: String
        let description: String
    }
}
