import SwiftUI
import SwiftData

struct ScheduleListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PreconditionSchedule.departureTime) private var schedules: [PreconditionSchedule]
    @State private var showAddSchedule = false

    var body: some View {
        List {
            if schedules.isEmpty {
                ContentUnavailableView(
                    "No Schedules",
                    systemImage: "clock.badge.plus",
                    description: Text("Create your first preconditioning schedule")
                )
            } else {
                ForEach(schedules) { schedule in
                    NavigationLink {
                        AddScheduleView(editingSchedule: schedule)
                    } label: {
                        ScheduleCard(schedule: schedule)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
                .onDelete(perform: deleteSchedules)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Schedules")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showAddSchedule = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddSchedule) {
            NavigationStack {
                AddScheduleView()
            }
        }
    }

    private func deleteSchedules(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(schedules[index])
        }
    }
}
