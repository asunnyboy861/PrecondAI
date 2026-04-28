import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var dashboardVM = DashboardViewModel()
    @Query private var vehicles: [Vehicle]
    @Query(filter: #Predicate<PreconditionSchedule> { $0.isEnabled }, sort: \PreconditionSchedule.departureTime) private var activeSchedules: [PreconditionSchedule]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if vehicles.isEmpty {
                    noVehicleView
                } else {
                    ForEach(vehicles) { vehicle in
                        VehicleCard(
                            vehicle: vehicle,
                            onCoolNow: { dashboardVM.quickCool(vehicle: vehicle) },
                            onHeatNow: { dashboardVM.quickHeat(vehicle: vehicle) },
                            onStop: { dashboardVM.stopPrecondition(vehicle: vehicle) }
                        )
                    }
                }

                if !activeSchedules.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Schedule")
                            .font(.headline)
                            .padding(.horizontal, 4)
                        ForEach(activeSchedules) { schedule in
                            ScheduleCard(schedule: schedule)
                        }
                    }
                }

                smartSuggestionSection
            }
            .padding()
        }
        .navigationTitle("PrecondAI")
        .frame(maxWidth: 720)
        .frame(maxWidth: .infinity)
    }

    private var noVehicleView: some View {
        VStack(spacing: 16) {
            Image(systemName: "car.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Vehicle Connected")
                .font(.title3)
                .fontWeight(.medium)
            Text("Add your EV to start smart preconditioning")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            NavigationLink("Add Vehicle", destination: VehicleAuthView())
                .buttonStyle(.borderedProminent)
        }
        .padding(40)
    }

    private var smartSuggestionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Smart Suggestion", systemImage: "lightbulb.fill")
                .font(.headline)
                .foregroundStyle(Color.appOrange)

            HStack {
                Image(systemName: "sun.max.fill")
                    .foregroundStyle(.orange)
                Text("Set up a schedule to auto-adjust based on weather")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(16)
            .background(Color.appOrange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

@Observable
final class DashboardViewModel {
    private let teslaClient = TeslaAPIClient()
    
    func quickCool(vehicle: Vehicle) {
        Task {
            do {
                try await teslaClient.startPreconditioning(vin: vehicle.vin ?? "")
            } catch {
                print("Quick cool failed: \(error)")
            }
        }
    }

    func quickHeat(vehicle: Vehicle) {
        Task {
            do {
                try await teslaClient.setTemperature(vin: vehicle.vin ?? "", driverTemp: 25.0)
                try await teslaClient.startPreconditioning(vin: vehicle.vin ?? "")
            } catch {
                print("Quick heat failed: \(error)")
            }
        }
    }

    func stopPrecondition(vehicle: Vehicle) {
        Task {
            do {
                try await teslaClient.stopPreconditioning(vin: vehicle.vin ?? "")
            } catch {
                print("Stop precondition failed: \(error)")
            }
        }
    }
}
