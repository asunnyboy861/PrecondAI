import Foundation
import BackgroundTasks
import UIKit

final class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()
    private let taskIdentifier = "com.zzoutuo.PrecondAI.precondition-task"

    func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task as! BGProcessingTask)
        }
    }

    func scheduleBackgroundProcessing(earliestBeginDate: Date) {
        let request = BGProcessingTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = earliestBeginDate
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {}
    }

    private func handleBackgroundTask(_ task: BGProcessingTask) {
        scheduleNextTask()
        task.setTaskCompleted(success: true)
    }

    private func scheduleNextTask() {
        let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        scheduleBackgroundProcessing(earliestBeginDate: nextDate)
    }
}
