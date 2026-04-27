import Foundation

extension Date {
    var shortTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var dayOfWeek: Int {
        Calendar.current.component(.weekday, from: self)
    }

    func adding(minutes: Int) -> Date {
        addingTimeInterval(Double(minutes) * 60)
    }
}
