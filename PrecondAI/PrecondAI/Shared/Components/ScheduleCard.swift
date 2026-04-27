import SwiftUI

struct ScheduleCard: View {
    let schedule: PreconditionSchedule
    var onToggle: () -> Void = {}
    var onEdit: () -> Void = {}
    var onDelete: () -> Void = {}

    private var daysText: String {
        schedule.daysOfWeek.sorted().map { dayNum in
            DayOfWeek(rawValue: dayNum)?.shortName ?? ""
        }.joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundStyle(.blue)
                Text(formatTime(schedule.departureTime))
                    .font(.headline)
                Text("Departure")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Toggle("", isOn: Binding(
                    get: { schedule.isEnabled },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .scaleEffect(0.8)
            }

            HStack {
                Label("Starts \(formatTime(schedule.optimalStartTime))", systemImage: "timer")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                if schedule.isWeatherAware {
                    Label("Weather-Aware", systemImage: "cloud.sun")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }
            }

            HStack {
                Text(daysText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(schedule.targetTemp))°F")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }

            HStack(spacing: 16) {
                Button("Edit", systemImage: "pencil") { onEdit() }
                    .font(.caption)
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
                    .font(.caption)
            }
        }
        .padding(16)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .opacity(schedule.isEnabled ? 1.0 : 0.5)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
