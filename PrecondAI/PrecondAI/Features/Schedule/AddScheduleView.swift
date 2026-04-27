import SwiftUI
import SwiftData

struct AddScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var vehicles: [Vehicle]

    let editingSchedule: PreconditionSchedule?

    @State private var departureTime = Date()
    @State private var targetTemp: Double = 72.0
    @State private var selectedDays: [Int] = [2, 3, 4, 5, 6]
    @State private var isWeatherAware = true
    @State private var notifyBeforeMinutes = 15
    @State private var selectedVehicleId: String = ""
    @State private var weatherPreviews: [WeatherPreviewItem] = []

    init(editingSchedule: PreconditionSchedule? = nil) {
        self.editingSchedule = editingSchedule
    }

    var body: some View {
        Form {
            Section("Departure Time") {
                DatePicker("Leave at", selection: $departureTime, displayedComponents: .hourAndMinute)
            }

            Section("Repeat") {
                DayOfWeekPicker(selectedDays: $selectedDays)
            }

            Section("Target Temperature") {
                TemperatureDial(temperature: $targetTemp, range: 55...85)
            }

            Section("Smart Features") {
                Toggle("Weather-Aware Adjustment", isOn: $isWeatherAware)
                if isWeatherAware {
                    WeatherPreviewCard(previews: weatherPreviews)
                }
            }

            Section("Notifications") {
                Picker("Remind before departure", selection: $notifyBeforeMinutes) {
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                    Text("15 minutes").tag(15)
                    Text("30 minutes").tag(30)
                }
            }

            if vehicles.count > 1 {
                Section("Vehicle") {
                    Picker("Vehicle", selection: $selectedVehicleId) {
                        ForEach(vehicles) { vehicle in
                            Text(vehicle.displayName).tag(vehicle.id)
                        }
                    }
                }
            }
        }
        .navigationTitle(editingSchedule == nil ? "New Schedule" : "Edit Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { saveSchedule() }
            }
        }
        .onAppear {
            if let schedule = editingSchedule {
                departureTime = schedule.departureTime
                targetTemp = schedule.targetTemp
                selectedDays = schedule.daysOfWeek
                isWeatherAware = schedule.isWeatherAware
                notifyBeforeMinutes = schedule.notifyBeforeMinutes
                selectedVehicleId = schedule.vehicleId
            } else if let first = vehicles.first {
                selectedVehicleId = first.id
            }
            generateWeatherPreview()
        }
        .onChange(of: targetTemp) { _, _ in generateWeatherPreview() }
        .onChange(of: isWeatherAware) { _, _ in generateWeatherPreview() }
    }

    private func saveSchedule() {
        if let schedule = editingSchedule {
            schedule.departureTime = departureTime
            schedule.targetTemp = targetTemp
            schedule.daysOfWeek = selectedDays
            schedule.isWeatherAware = isWeatherAware
            schedule.notifyBeforeMinutes = notifyBeforeMinutes
            schedule.preconditionMinutes = calculatePreconditionMinutes()
            schedule.optimalStartTime = departureTime.adding(minutes: -schedule.preconditionMinutes)
        } else {
            let minutes = calculatePreconditionMinutes()
            let schedule = PreconditionSchedule(
                vehicleId: selectedVehicleId,
                departureTime: departureTime,
                optimalStartTime: departureTime.adding(minutes: -minutes),
                targetTemp: targetTemp,
                daysOfWeek: selectedDays,
                isWeatherAware: isWeatherAware,
                preconditionMinutes: minutes,
                notifyBeforeMinutes: notifyBeforeMinutes
            )
            modelContext.insert(schedule)
        }
        dismiss()
    }

    private func calculatePreconditionMinutes() -> Int {
        SmartPreconditionCalculator.calculatePreconditionMinutes(
            targetTemp: targetTemp,
            outsideTemp: 50,
            isPluggedIn: true,
            batteryLevel: 80,
            weatherCondition: .cloudy
        ) ?? 20
    }

    private func generateWeatherPreview() {
        guard isWeatherAware else {
            weatherPreviews = []
            return
        }
        let calendar = Calendar.current
        let today = Date()
        weatherPreviews = (0..<5).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: today) else { return nil }
            let outsideTemp = 30.0 + Double(offset) * 5.0
            let minutes = SmartPreconditionCalculator.calculatePreconditionMinutes(
                targetTemp: targetTemp,
                outsideTemp: outsideTemp,
                isPluggedIn: true,
                batteryLevel: 80,
                weatherCondition: offset % 2 == 0 ? .cloudy : .sunny
            )
            return WeatherPreviewItem(date: date, outsideTemp: outsideTemp, condition: offset % 2 == 0 ? .cloudy : .sunny, preconditionMinutes: minutes)
        }
    }
}
