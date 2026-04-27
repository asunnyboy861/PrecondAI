import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case unauthorized
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case vehicleOffline
    case batteryTooLow
    case rateLimited
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .unauthorized: return "Authentication required. Please sign in again."
        case .networkError(let error): return error.localizedDescription
        case .invalidResponse: return "Invalid server response"
        case .decodingError(let error): return "Data error: \(error.localizedDescription)"
        case .vehicleOffline: return "Vehicle is offline. Please wake it up first."
        case .batteryTooLow: return "Battery too low for preconditioning"
        case .rateLimited: return "Too many requests. Please wait a moment."
        case .unknown(let msg): return msg
        }
    }
}
