import SwiftUI

struct WeatherPreviewCard: View {
    let previews: [WeatherPreviewItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Weather Preview", systemImage: "cloud.sun")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text(" Weather")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            ForEach(previews.prefix(5)) { item in
                HStack {
                    Text(formatDay(item.date))
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                    Image(systemName: item.condition.iconName)
                        .font(.caption)
                        .foregroundStyle(conditionColor(item.condition))
                        .frame(width: 20)
                    Text("\(Int(item.outsideTemp))°F")
                        .font(.caption)
                        .frame(width: 45, alignment: .trailing)
                    if let minutes = item.preconditionMinutes {
                        Text("Start \(minutes) min early")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Battery too low")
                            .font(.caption2)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private func conditionColor(_ condition: WeatherCondition) -> Color {
        switch condition {
        case .snow, .ice: return .cyan
        case .heavyRain, .lightRain: return .blue
        case .sunny, .clear: return .orange
        default: return .gray
        }
    }
}
