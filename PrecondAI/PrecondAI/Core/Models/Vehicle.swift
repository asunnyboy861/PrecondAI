import Foundation
import SwiftData

@Model
final class Vehicle {
    @Attribute(.unique) var id: String
    var brand: String
    var model: String
    var year: Int
    var displayName: String
    var vin: String?
    var isTeslaConnected: Bool
    var lastAuthDate: Date?
    var batteryLevel: Int
    var chargingState: String
    var isClimateOn: Bool
    var insideTemp: Double?
    var outsideTemp: Double?
    var lastUpdated: Date

    init(brand: String, model: String, year: Int, displayName: String) {
        self.id = UUID().uuidString
        self.brand = brand
        self.model = model
        self.year = year
        self.displayName = displayName
        self.vin = nil
        self.isTeslaConnected = false
        self.lastAuthDate = nil
        self.batteryLevel = 0
        self.chargingState = "UNKNOWN"
        self.isClimateOn = false
        self.lastUpdated = Date()
    }
}

enum VehicleBrand: String, Codable, CaseIterable {
    case tesla = "Tesla"
    case ford = "Ford"
    case bmw = "BMW"
    case mercedes = "Mercedes"
    case rivian = "Rivian"
    case hyundai = "Hyundai"
    case kia = "Kia"
    case volkswagen = "Volkswagen"
    case chevrolet = "Chevrolet"
    case nissan = "Nissan"
    case audi = "Audi"
    case porsche = "Porsche"
    case volvo = "Volvo"
    case polestar = "Polestar"
}

enum ChargingState: String, Codable {
    case pluggedIn = "PLUGGED_IN"
    case charging = "CHARGING"
    case unplugged = "UNPLUGGED"
    case unknown = "UNKNOWN"
}
