import SwiftUI

struct VehicleCard: View {
    let vehicle: Vehicle
    var onCoolNow: () -> Void = {}
    var onHeatNow: () -> Void = {}
    var onStop: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "car.fill")
                    .font(.title2)
                Text(vehicle.displayName)
                    .font(.headline)
                Spacer()
                Circle()
                    .fill(vehicle.isClimateOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 10, height: 10)
            }

            HStack(spacing: 16) {
                StatBox(icon: "thermometer.medium", value: vehicle.insideTemp.map { "\(Int($0))°F" } ?? "--", label: "Inside")
                StatBox(icon: "battery.75", value: "\(vehicle.batteryLevel)%", label: "Battery")
                StatBox(icon: vehicle.chargingState == "CHARGING" ? "bolt.fill" : "bolt.slash", value: chargingLabel, label: "Charging")
                StatBox(icon: "thermometer.sun", value: vehicle.outsideTemp.map { "\(Int($0))°F" } ?? "--", label: "Outside")
            }

            HStack(spacing: 12) {
                ActionButton(title: "Cool Now", icon: "snowflake", color: .blue, action: onCoolNow)
                ActionButton(title: "Heat Now", icon: "flame.fill", color: .orange, action: onHeatNow)
                ActionButton(title: "Stop", icon: "stop.fill", color: .gray, action: onStop)
            }
        }
        .padding(20)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var chargingLabel: String {
        switch vehicle.chargingState {
        case "CHARGING": return "Active"
        case "PLUGGED_IN": return "Plugged"
        case "UNPLUGGED": return "Off"
        default: return "--"
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}
