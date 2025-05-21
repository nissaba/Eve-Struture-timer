// EventFormViewModel.swift

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class EventFormViewModel: ObservableObject {
    // MARK: - Dependencies
    private let context: ModelContext

    // MARK: - Input Properties
    @Published var systemName: String = ""
    @Published var planetNumber: String = ""
    @Published var eventStartTime: String = ""
    @Published var timeToAdd: String = ""
    @Published var isDefenseTimer: Bool = false

    // MARK: - Output
    @Published var resultText: String = Constants.enterData
    @Published var fromDate: Date?

    // MARK: - Validation Flags
    @Published var isSystemNameValid = false
    @Published var isPlanetNumberValid = false
    @Published var isEventStartTimeValid = true
    @Published var isTimeToAddValid = false

    // MARK: - Editing Existing Event
    private let editingEvent: ReinforcementTimeEvent?

    // MARK: - Computed
    var isAllValid: Bool {
        isSystemNameValid && isPlanetNumberValid && isEventStartTimeValid && isTimeToAddValid
    }

    // MARK: - Init
    init(context: ModelContext, editingEvent: ReinforcementTimeEvent? = nil) {
        self.context = context
        self.editingEvent = editingEvent

        if let event = editingEvent {
            systemName = event.systemName
            planetNumber = "\(event.planet)"
            fromDate = event.createdDate
            isDefenseTimer = event.isDefence
            timeToAdd = Self.formatRemainingTime(event.remainingTime)
        }
    }

    // MARK: - Actions

    func saveEvent() {
        guard let planet = Int8(planetNumber) else {
            resultText = Constants.missingPlanetNumber
            return
        }

        guard let date = fromDate else {
            resultText = Constants.badDate
            return
        }

        if let event = editingEvent {
            updateEvent(event, with: date)
        } else if let existingEvent = fetchEvent(systemName: systemName, planet: planet) {
            updateEvent(existingEvent, with: date)
        } else {
            createNewEvent(systemName: systemName, planet: planet, date: date, isDefence: isDefenseTimer)
        }
    }

    func calculateFutureTime() {
        guard let startDate = createStartDate(), let timeOffset = parseTimeOffset() else {
            resultText = Constants.invalidInput
            return
        }
        let finalDate = startDate.addingTimeInterval(timeOffset)
        fromDate = startDate
        resultText = formatDate(finalDate)
    }

    // MARK: - Helpers

    private func updateEvent(_ event: ReinforcementTimeEvent, with date: Date) {
        guard let timeDelta = parseTimeOffset() else { return }
        context.updateEvent(
            event,
            newSystemName: systemName,
            newPlanet: Int8(planetNumber),
            newCreatedDate: date,
            timeRemaining: timeDelta,
            newIsDefence: isDefenseTimer
        )
    }

    private func createNewEvent(systemName: String, planet: Int8, date: Date, isDefence: Bool) {
        guard let timeTo = parseTimeOffset() else { return }
        context.addEvent(
            systemName: systemName,
            planet: planet,
            createdDate: date,
            timeInterval: timeTo,
            isDefence: isDefence
        )
    }

    private func fetchEvent(systemName: String, planet: Int8) -> ReinforcementTimeEvent? {
        let predicate = #Predicate<ReinforcementTimeEvent> { event in
            event.systemName == systemName && event.planet == planet
        }
        let descriptor = FetchDescriptor<ReinforcementTimeEvent>(predicate: predicate)
        return try? context.fetch(descriptor).first
    }

    private func parseTimeOffset() -> TimeInterval? {
        let timeComponents = timeToAdd.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == Constants.timeComponentCount else { return nil }
        return TimeInterval(timeComponents[0] * Constants.secondsPerDay + timeComponents[1] * Constants.secondsPerHour + timeComponents[2] * Constants.secondsPerMinute)
    }

    private func createStartDate() -> Date? {
        let calendar = Calendar.current
        let now = Date()
        let eventComponents = eventStartTime.split(separator: ":").compactMap { Int($0) }

        guard eventComponents.count == Constants.eventTimeComponentCount else { return now }

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = eventComponents[0]
        components.minute = eventComponents[1]

        return calendar.date(from: components)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .init(abbreviation: Constants.utcAbbreviation)
        formatter.dateFormat = Constants.dateFormatString
        return formatter.string(from: date)
    }

    private static func formatRemainingTime(_ seconds: TimeInterval) -> String {
        guard seconds > 0 else { return Constants.defaultFormattedTime }
        let days = Int(seconds) / Constants.secondsPerDay
        let hours = (Int(seconds) % Constants.secondsPerDay) / Constants.secondsPerHour
        let minutes = (Int(seconds) % Constants.secondsPerHour) / Constants.secondsPerMinute
        return String(format: Constants.remainingTimeFormat, days, hours, minutes)
    }

    // MARK: - Constants

    private enum Constants {
        static let enterData = "Enter Information"
        static let missingPlanetNumber = "Planet Number Missing"
        static let badDate = "Bad date"
        static let invalidInput = "Invalid input"

        static let secondsPerDay = 86400
        static let secondsPerHour = 3600
        static let secondsPerMinute = 60

        static let timeComponentCount = 3
        static let eventTimeComponentCount = 2

        static let dateFormatString = "dd/MM/yyyy HH:mm"
        static let utcAbbreviation = "UTC"
        static let defaultFormattedTime = "00:00:00"
        static let remainingTimeFormat = "%d:%02d:%02d"
    }
}
