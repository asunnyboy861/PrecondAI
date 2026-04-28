import Foundation

actor TeslaAPIClient {
    private let baseURL = "https://fleet-api.prd.na.vn.cloud.tesla.com"

    private var accessToken: String? {
        get throws {
            return try KeychainTokenStorage.getAccessToken()
        }
    }

    func startPreconditioning(vin: String) async throws {
        let token = try await getValidToken()
        let endpoint = "/api/1/vehicles/\(vin)/command/auto_conditioning_start"
        try await sendCommand(endpoint: endpoint, body: [:], token: token)
    }

    func stopPreconditioning(vin: String) async throws {
        let token = try await getValidToken()
        let endpoint = "/api/1/vehicles/\(vin)/command/auto_conditioning_stop"
        try await sendCommand(endpoint: endpoint, body: [:], token: token)
    }

    func setTemperature(vin: String, driverTemp: Double, passengerTemp: Double? = nil) async throws {
        let token = try await getValidToken()
        let endpoint = "/api/1/vehicles/\(vin)/command/set_temps"
        var body: [String: Any] = ["driver_temp": driverTemp]
        if let pt = passengerTemp {
            body["passenger_temp"] = pt
        }
        try await sendCommand(endpoint: endpoint, body: body, token: token)
    }

    func getVehicleData(vin: String) async throws -> TeslaVehicleData {
        let token = try await getValidToken()
        let endpoint = "/api/1/vehicles/\(vin)/vehicle_data"
        return try await sendRequest(endpoint: endpoint, token: token)
    }

    func wakeUp(vin: String) async throws {
        let token = try await getValidToken()
        let endpoint = "/api/1/vehicles/\(vin)/wake_up"
        try await sendCommand(endpoint: endpoint, body: [:], token: token)
    }

    private func getValidToken() async throws -> String {
        guard let token = try accessToken else {
            throw APIError.unauthorized
        }
        return token
    }

    private func sendCommand(endpoint: String, body: [String: Any], token: String) async throws {
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !body.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if httpResponse.statusCode == 401 { throw APIError.unauthorized }
        if httpResponse.statusCode == 429 { throw APIError.rateLimited }
        if !(200...299).contains(httpResponse.statusCode) { throw APIError.unknown("Command failed: \(httpResponse.statusCode)") }
    }

    private func sendRequest<T: Decodable>(endpoint: String, token: String) async throws -> T {
        let url = URL(string: baseURL + endpoint)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        if httpResponse.statusCode == 401 { throw APIError.unauthorized }
        if !(200...299).contains(httpResponse.statusCode) { throw APIError.unknown("Request failed: \(httpResponse.statusCode)") }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}

struct TeslaVehicleData: Codable {
    let response: TeslaVehicleState?
}

struct TeslaVehicleState: Codable {
    let state: String?
    let chargeState: TeslaChargeState?
    let climateState: TeslaClimateState?
    let driveState: TeslaDriveState?

    enum CodingKeys: String, CodingKey {
        case state
        case chargeState = "charge_state"
        case climateState = "climate_state"
        case driveState = "drive_state"
    }
}

struct TeslaChargeState: Codable {
    let batteryLevel: Int?
    let chargingState: String?

    enum CodingKeys: String, CodingKey {
        case batteryLevel = "battery_level"
        case chargingState = "charging_state"
    }
}

struct TeslaClimateState: Codable {
    let insideTemp: Double?
    let outsideTemp: Double?
    let isClimateOn: Bool?
    let driverTempSetting: Double?

    enum CodingKeys: String, CodingKey {
        case insideTemp = "inside_temp"
        case outsideTemp = "outside_temp"
        case isClimateOn = "is_climate_on"
        case driverTempSetting = "driver_temp_setting"
    }
}

struct TeslaDriveState: Codable {
    let latitude: Double?
    let longitude: Double?

    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}
