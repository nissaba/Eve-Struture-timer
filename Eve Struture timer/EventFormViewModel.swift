import Foundation
import SwiftData

/// ViewModel responsible for managing user input, validation, and event persistence for the reinforcement timer form.
@Observable
final class EventFormViewModel {
    
    // MARK: - Published Inputs

    var systemName: String = "" {
        didSet { validateSystemName() }
    }

    var planetNumber: String = "" {
        didSet { validatePlanetNumber() }
    }

    var eventStartTime: String = "" {
        didSet { validateEventStartTime() }
    }

    var timeToAdd: String = "" {
        didSet { validateTimeToAdd() }
    }

    var isDefenseTimer: Bool = false
    
    // MARK: - Published Validation Errors

    var systemNameError: String? = nil
    var planetNumberError: String? = nil
    var eventStartTimeError: String? = nil
    var timeToAddError: String? = nil

    // MARK: - Computed Validation State

    @ObservationIgnored var isAllValid: Bool {
        systemNameError == nil &&
        planetNumberError == nil &&
        eventStartTimeError == nil &&
        timeToAddError == nil
    }

    // MARK: - Output

    var resultText: String = Constants.defaultResultText
    var fromDate: Date? = nil

    // MARK: - Dependencies

    private let context: ModelContext
    private let editingEvent: ReinforcementTimeEvent?

    // MARK: - Init

    init(context: ModelContext, editingEvent: ReinforcementTimeEvent? = nil) {
        self.context = context
        self.editingEvent = editingEvent

        if let event = editingEvent {
            systemName = event.systemName
            planetNumber = "\(event.planet)"
            fromDate = event.createdDate
            isDefenseTimer = event.isDefence

            let remainingTime = event.remainingTime

            if remainingTime > 0 {
                let days = Int(remainingTime) / Constants.secondsPerDay
                let hours = (Int(remainingTime) % Constants.secondsPerDay) / Constants.secondsPerHour
                let minutes = (Int(remainingTime) % Constants.secondsPerHour) / Constants.secondsPerMinute
                timeToAdd = String(format: Constants.timeFormat, days, hours, minutes)
            } else {
                timeToAdd = Constants.defaultTimeToAdd
            }
        }
    }

    // MARK: - Validation Entry Points

    func validateSystemName() {
        if systemName.range(of: Constants.systemNamePattern, options: .regularExpression) == nil {
            systemNameError = Constants.systemNameError
        } else {
            systemNameError = nil
        }
    }

    func validatePlanetNumber() {
        if planetNumber.range(of: Constants.planetNumberPattern, options: .regularExpression) == nil {
            planetNumberError = Constants.planetNumberError
        } else {
            planetNumberError = nil
        }
    }

    func validateEventStartTime() {
        if eventStartTime.range(of: Constants.optionalTimePattern, options: .regularExpression) == nil {
            eventStartTimeError = Constants.optionalTimeError
        } else {
            eventStartTimeError = nil
        }
    }

    func validateTimeToAdd() {
        if timeToAdd.range(of: Constants.timeRemaningPattern, options: .regularExpression) == nil {
            timeToAddError = Constants.timeToAddError
        } else {
            timeToAddError = nil
        }
    }

    // MARK: - Actions

    func calculateFutureTime() {
        guard let startDate = createStartDate() else {
            resultText = Constants.invalidEventTimeMessage
            return
        }
        guard let timeOffset = parseTimeOffset() else {
            resultText = Constants.invalidAddTimeMessage
            return
        }
        let finalDate = startDate.addingTimeInterval(timeOffset)
        fromDate = finalDate
        resultText = formatDate(finalDate)
    }

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
            createNewEvent(systemName: systemName,
                           planet: planet,
                           date: date,
                           timeToAdd: timeToAdd,
                           isDefence: isDefenseTimer)
        }
    }

    // MARK: - Internal Logic

    private func timeInterval(from formattedString: String) -> TimeInterval? {
        let components = formattedString.split(separator: ":").map { String($0) }
        guard components.count == 3,
              let days = Int(components[0]),
              let hours = Int(components[1]),
              let minutes = Int(components[2]) else {
            return nil
        }
        return TimeInterval(days * Constants.secondsPerDay + hours * Constants.secondsPerHour + minutes * Constants.secondsPerMinute)
    }

    private func updateEvent(_ event: ReinforcementTimeEvent, with date: Date) {
        guard let timeDelta = timeInterval(from: timeToAdd) else { return }
        context.updateEvent(event,
                            newSystemName: systemName,
                            newPlanet: Int8(planetNumber),
                            newCreatedDate: date,
                            timeRemaining: timeDelta,
                            newIsDefence: isDefenseTimer)
    }

    private func createNewEvent(systemName: String, planet: Int8, date: Date, timeToAdd: String, isDefence: Bool) {
        guard let timeTo = timeInterval(from: timeToAdd) else { return }
        context.addEvent(systemName: systemName,
                         planet: planet,
                         createdDate: date,
                         timeInterval: timeTo,
                         isDefence: isDefence)
    }

    private func fetchEvent(systemName: String, planet: Int8) -> ReinforcementTimeEvent? {
        let predicate = #Predicate<ReinforcementTimeEvent> { event in
            event.systemName == systemName && event.planet == planet
        }
        let fetchDescriptor = FetchDescriptor<ReinforcementTimeEvent>(predicate: predicate)
        return try? context.fetch(fetchDescriptor).first
    }

    private func createStartDate() -> Date? {
        let calendar = Calendar.current
        let currentDate = Date()
        let eventComponents = eventStartTime.split(separator: ":").compactMap { Int($0) }
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)

        guard eventComponents.count == 2 else { return currentDate }

        components.hour = eventComponents.first
        components.minute = eventComponents.last

        return calendar.date(from: components)
    }

    private func parseTimeOffset() -> TimeInterval? {
        let timeComponents = timeToAdd.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == 3 else { return nil }

        let days = timeComponents[0]
        let hours = timeComponents[1]
        let minutes = timeComponents[2]

        return TimeInterval(days * Constants.secondsPerDay + hours * Constants.secondsPerHour + minutes * Constants.secondsPerMinute)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = Constants.dateFormat
        return formatter.string(from: date)
    }
}

// MARK: - Constants

private extension EventFormViewModel {
    struct Constants {
        static let defaultResultText = "Enter Data"
        static let defaultTimeToAdd = "00:00:00"
        static let timeFormat = "%d:%02d:%02d"

        static let secondsPerDay = 86400
        static let secondsPerHour = 3600
        static let secondsPerMinute = 60

        static let dateFormat = "dd/MM/yyyy HH:mm"

        static let systemNamePattern = "^[a-zA-Z0-9]+(?:[- ]?[a-zA-Z0-9]+)*$"
        static let planetNumberPattern = "^[1-9][0-9]*$"
        static let optionalTimePattern = "^$|^(?:\\d{1,2}h\\d{1,2}m|\\d{1,2}h|\\d{1,2}m)$"
        static let timeRemaningPattern = "^(0|1):(0[0-9]|1[0-9]|2[0-3]):(0[0-9]|[1-5][0-9]|60)$"

        static let systemNameError = "Only letters, numbers, spaces, and a single hyphen are allowed."
        static let planetNumberError = "Enter a valid positive planet number."
        static let optionalTimeError = "Expected format like '3h', '45m', '2h30m' or leave blank."
        static let timeToAddError = "Expected format like '1d', '3h', '45m', '2h30m'."

        static let invalidEventTimeMessage = "Invalid event time input"
        static let invalidAddTimeMessage = "Invalid time to add input"
        static let badDate = "Bad date"
        static let missingPlanetNumber = "Planet Number Missing"
    }
}

