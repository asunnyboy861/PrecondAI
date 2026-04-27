import SwiftUI
import SwiftData

@main
struct PrecondAIApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .modelContainer(for: [Vehicle.self, PreconditionSchedule.self])
    }
}

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)

            NavigationStack {
                ScheduleListView()
            }
            .tabItem {
                Label("Schedules", systemImage: "calendar")
            }
            .tag(1)

            NavigationStack {
                VehicleAuthView()
            }
            .tabItem {
                Label("Vehicle", systemImage: "car.fill")
            }
            .tag(2)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
            .tag(3)
        }
    }
}
