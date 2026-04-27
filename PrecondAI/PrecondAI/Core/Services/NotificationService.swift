import Foundation
import UserNotifications

@Observable
final class NotificationService {
    var isAuthorized = false

    func requestAuthorization() async -> Bool {
        do {
            isAuthorized = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return isAuthorized
        } catch {
            return false
        }
    }

    func sendConfirmation(title: String, body: String) async throws {
        guard isAuthorized else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        try await UNUserNotificationCenter.current().add(request)
    }

    func scheduleReminder(title: String, body: String, at date: Date) async throws {
        guard isAuthorized else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date), repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        try await UNUserNotificationCenter.current().add(request)
    }

    func sendAlert(title: String, body: String) async throws {
        try await sendConfirmation(title: title, body: body)
    }
}
