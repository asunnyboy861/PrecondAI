import SwiftUI

struct DayOfWeekPicker: View {
    @Binding var selectedDays: [Int]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(DayOfWeek.allCases, id: \.rawValue) { day in
                DayButton(day: day, isSelected: selectedDays.contains(day.rawValue)) {
                    toggleDay(day.rawValue)
                }
            }
        }
    }

    private func toggleDay(_ rawValue: Int) {
        if selectedDays.contains(rawValue) {
            selectedDays.removeAll { $0 == rawValue }
        } else {
            selectedDays.append(rawValue)
        }
    }
}

struct DayButton: View {
    let day: DayOfWeek
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(day.shortName)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: 36, height: 36)
                .foregroundStyle(isSelected ? .white : .primary)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .clipShape(Circle())
        }
    }
}
