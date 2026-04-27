import Foundation
import CoreLocation

@Observable
final class WeatherService {
    private let apiClient: WeatherAPIClient

    init(apiClient: WeatherAPIClient) {
        self.apiClient = apiClient
    }

    func getWeatherForLocation(_ location: CLLocation) async throws -> WeatherData {
        return try await apiClient.getCurrentWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }

    func getWeatherForCoordinates(lat: Double, lon: Double) async throws -> WeatherData {
        return try await apiClient.getCurrentWeather(lat: lat, lon: lon)
    }
}
