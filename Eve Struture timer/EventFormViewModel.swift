// EventFormViewModel.swift
import Foundation
import SwiftData

@Observable
class EventFormViewModel {
    let context: ModelContext

    // MARK: - Input fields
    var systemName: String = ""
    var planetNumber: String = ""
    var eventStartTime: String = ""   // Optional start time (HH:mm)
    var timeToAdd: String = ""        // Duration input (e.g., 1j2h30m)
    var isDefenseTimer: Bool = false

    // MARK: - Output and state
    var resultText: String = Constants.enterData
    var fromDate: Date?

    // MARK: - Validation flags
    var isSystemNameValid = false
    var isPlanetNumberValid = false
    var isEventStartTimeValid = true
    var isTimeToAddValid = false

    // MARK: - Editing mode
    let editingEvent: ReinforcementTimeEvent?

    var isAllValid: Bool {
        isSystemNameValid && isPlanetNumberValid && isEventStartTimeValid && isTimeToAddValid
    }

    init(context: ModelContext, editingEvent: ReinforcementTimeEvent? = nil) {
        self.context = context
        self.editingEvent = editingEvent

        if let event = editingEvent {
            self.systemName = event.systemName
            self.planetNumber = "\(event.planet)"
            self.fromDate = event.createdDate
            self.isDefenseTimer = event.isDefence

            let remainingTime = event.remainingTime
            self.timeToAdd = Self.formatTimeInterval(remainingTime)
        }
    }

    func calculateFutureTime() {
        guard let start = createStartDate() else {
            resultText = Constants.invalidEventTimeMessage
            return
        }

        guard let offset = Self.parseFlexibleDuration(timeToAdd) else {
            resultText = Constants.invalidAddTimeMessage
            return
        }

        let finalDate = start.addingTimeInterval(offset)
        fromDate = start
        resultText = Self.formatDate(finalDate)
    }

    private func createStartDate() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let components = eventStartTime.split(separator: ":").compactMap { Int($0) }

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: now)

        if components.count == 2 {
            dateComponents.hour = components[0]
            dateComponents.minute = components[1]
        } else {
            return now
        }

        return calendar.date(from: dateComponents)
    }

    // MARK: - Helpers

    static func parseFlexibleDuration(_ input: String) -> TimeInterval? {
        let pattern = Constants.durationPattern

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: input, range: NSRange(input.startIndex..., in: input)) else {
            return nil
        }

        func extract(_ index: Int) -> Int {
            guard let range = Range(match.range(at: index), in: input),
                  let value = Int(input[range]) else { return 0 }
            return value
        }

        let days = extract(1)
        let hours = extract(2)
        let minutes = extract(3)

        return TimeInterval(days * Constants.secondsPerDay + hours * Constants.secondsPerHour + minutes * Constants.secondsPerMinute)
    }

    static func formatTimeInterval(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval) / Constants.secondsPerMinute
        let days = totalMinutes / Constants.minutesPerDay
        let hours = (totalMinutes % Constants.minutesPerDay) / Constants.minutesPerHour
        let minutes = totalMinutes % Constants.minutesPerHour

        var parts: [String] = []
        if days > 0 { parts.append(String(format: Constants.formatDays, days)) }
        if hours > 0 { parts.append(String(format: Constants.formatHours, hours)) }
        if minutes > 0 { parts.append(String(format: Constants.formatMinutes, minutes)) }

        return parts.isEmpty ? "0m" : parts.joined()
    }

    static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = Constants.dateFormatString
        return formatter.string(from: date)
    }
}

// MARK: - Constants

extension EventFormViewModel {
    struct Constants {
        static let formatDays = "%dj"
        static let formatHours = "%dh"
        static let formatMinutes = "%dm"
        static let enterData = "Enter Information"
        static let invalidEventTimeMessage = "Invalid event time input"
        static let invalidAddTimeMessage = "Invalid time to add input"
        static let dateFormatString = "dd/MM/yyyy HH:mm"
        static let durationPattern = "^(?:(\\d+)j)?(?:(\\d+)h)?(?:(\\d+)m)?$"

        static let secondsPerMinute = 60
        static let secondsPerHour = 3600
        static let secondsPerDay = 86400
        static let minutesPerHour = 60
        static let minutesPerDay = 1440
    }
}

