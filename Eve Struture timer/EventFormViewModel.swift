import Foundation
import SwiftData

/// ViewModel responsible for managing user input, validation, and event persistence for the reinforcement timer form.
@Observable
final class EventFormViewModel {
    
    // MARK: - Published Inputs

    /// User input for system (solar) name. Validated on change.
    var systemName: String = "" {
        didSet { validateSystemName() }
    }

    var isUTC: Bool = true {
        didSet {
            if isAllValid {
                calculateFutureTime()
            }
        }
    }
    
    /// User input for planet number. Validated on change.
    var planetNumber: String = "" {
        didSet { validatePlanetNumber() }
    }

    /// User input for event start time
    var eventStartTime: Date = Date()

    /// User input for additional time to add to the event (e.g., 1d2h30m). Validated on change.
    var timeToAdd: String = "" {
        didSet { validateTimeToAdd() }
    }

    /// Indicates if this is a defense timer event.
    var isDefenseTimer: Bool = false
    
    // MARK: - Published Validation Errors

    /// Validation error message (or nil) for the system name field.
    var systemNameError: String? = nil

    /// Validation error message (or nil) for the planet number field.
    var planetNumberError: String? = nil


    /// Validation error message (or nil) for the time to add field.
    var timeToAddError: String? = nil

    // MARK: - Computed Validation State

    /// Returns true if all validation errors are nil.
    @ObservationIgnored var isAllValid: Bool {
        systemNameError == nil &&
        planetNumberError == nil &&
        timeToAddError == nil
    }

    // MARK: - Output

    /// Result string shown to user with the calculated future date/time.
    var resultText: String = Constants.defaultResultText

    // MARK: - Dependencies

    /// Reference to the SwiftData model context for persistence.
    private let context: ModelContext

    /// Optional event being edited; if nil, form creates a new event.
    private let editingEvent: ReinforcementTimeEvent?

    // MARK: - Init

    /// Initializes the ViewModel with optional existing event for editing.
    /// Sets initial field values based on the event if present.
    init(context: ModelContext, editingEvent: ReinforcementTimeEvent? = nil) {
        self.context = context
        self.editingEvent = editingEvent

        if let event = editingEvent {
            systemName = event.systemName
            planetNumber = "\(event.planet)"
            eventStartTime = event.createdDate
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

    /// Validates the system name and sets the error message.
    func validateSystemName() {
        if systemName.range(of: Constants.systemNamePattern, options: .regularExpression) == nil {
            systemNameError = Constants.systemNameError
        } else {
            systemNameError = nil
        }
    }

    /// Validates the planet number and sets the error message.
    func validatePlanetNumber() {
        if planetNumber.range(of: Constants.planetNumberPattern, options: .regularExpression) == nil {
            planetNumberError = Constants.planetNumberError
        } else {
            planetNumberError = nil
        }
    }

    /// Validates the time to add and sets the error message.
    func validateTimeToAdd() {
        if timeToAdd.range(of: Constants.timeRemaningPattern, options: .regularExpression) == nil {
            timeToAddError = Constants.timeToAddError
        } else {
            timeToAddError = nil
        }
    }

    // MARK: - Actions

    /// Calculates the resulting event date/time based on user inputs.
    /// Updates resultText and fromDate accordingly.
    func calculateFutureTime() {
        
        
        guard let timeOffset = parseTimeOffset() else {
            resultText = Constants.invalidAddTimeMessage
            return
        }
        let finalDate = eventStartTime.addingTimeInterval(timeOffset)
        resultText = formatDate(finalDate)
    }

    /// Persists the new or updated event based on form state.
    /// Validates necessary inputs before saving.
    func saveEvent() {
        guard let planet = Int8(planetNumber) else {
            resultText = Constants.missingPlanetNumber
            return
        }


        if let event = editingEvent {
            updateEvent(event, with: eventStartTime)
        } else if let existingEvent = fetchEvent(systemName: systemName, planet: planet) {
            updateEvent(existingEvent, with: eventStartTime)
        } else {
            createNewEvent(systemName: systemName,
                           planet: planet,
                           date: eventStartTime,
                           timeToAdd: timeToAdd,
                           isDefence: isDefenseTimer)
        }
    }

    // MARK: - Internal Logic

    /// Converts a formatted time string (dd:hh:mm) into a TimeInterval in seconds.
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

    /// Updates an existing event with new values.
    private func updateEvent(_ event: ReinforcementTimeEvent, with date: Date) {
        guard let timeDelta = timeInterval(from: timeToAdd) else { return }
        context.updateEvent(event,
                            newSystemName: systemName,
                            newPlanet: Int8(planetNumber),
                            newCreatedDate: date,
                            timeRemaining: timeDelta,
                            newIsDefence: isDefenseTimer)
    }

    /// Creates a new event with specified parameters.
    private func createNewEvent(systemName: String, planet: Int8, date: Date, timeToAdd: String, isDefence: Bool) {
        guard let timeTo = timeInterval(from: timeToAdd) else { return }
        context.addEvent(systemName: systemName,
                         planet: planet,
                         createdDate: date,
                         timeInterval: timeTo,
                         isDefence: isDefence)
    }

    /// Fetches an existing event matching the given system name and planet.
    private func fetchEvent(systemName: String, planet: Int8) -> ReinforcementTimeEvent? {
        let predicate = #Predicate<ReinforcementTimeEvent> { event in
            event.systemName == systemName && event.planet == planet
        }
        let fetchDescriptor = FetchDescriptor<ReinforcementTimeEvent>(predicate: predicate)
        return try? context.fetch(fetchDescriptor).first
    }


    /// Parses the timeToAdd string into a TimeInterval (seconds).
    private func parseTimeOffset() -> TimeInterval? {
        let timeComponents = timeToAdd.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == 3 else { return nil }

        let days = timeComponents[0]
        let hours = timeComponents[1]
        let minutes = timeComponents[2]

        return TimeInterval(days * Constants.secondsPerDay + hours * Constants.secondsPerHour + minutes * Constants.secondsPerMinute)
    }

    /// Formats a Date object into a string using the specified date format and UTC timezone.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = isUTC ? TimeZone(abbreviation: "UTC") : TimeZone.current
        formatter.dateFormat = Constants.dateFormat
        return formatter.string(from: date)
    }
}

// MARK: - Constants

private extension EventFormViewModel {
    struct Constants {
        // Default text for result label when form is empty.
        static let defaultResultText = "Enter Data"
        // Default formatted time string for new events.
        static let defaultTimeToAdd = "00:00:00"
        // Format string for displaying days, hours, and minutes.
        static let timeFormat = "%d:%02d:%02d"

        // Number of seconds in a day.
        static let secondsPerDay = 86400
        // Number of seconds in an hour.
        static let secondsPerHour = 3600
        // Number of seconds in a minute.
        static let secondsPerMinute = 60

        // Date format for displaying the event date.
        static let dateFormat = "dd/MM/yyyy HH:mm"

        // Regex for validating system name input.
        static let systemNamePattern = "^[a-zA-Z0-9]+(?:[- ]?[a-zA-Z0-9]+)*$"
        // Regex for validating planet number input.
        static let planetNumberPattern = "^[1-9][0-9]*$"
        // Regex for validating event start time input as dd/mm/yyyy.
        static let optionalTimePattern = "^(0[1-9]|[12][0-9]|3[01])\\/(0[1-9]|1[0-2])\\/\\d{4}$"
        // Regex for validating time to add input in dd:hh:mm format.
        static let timeRemaningPattern = "^(0|1):(0[0-9]|1[0-9]|2[0-3]):(0[0-9]|[1-5][0-9]|60)$"

        // Error message for invalid system name input.
        static let systemNameError = "Only letters, numbers, spaces, and a single hyphen are allowed."
        // Error message for invalid planet number input.
        static let planetNumberError = "Enter a valid positive planet number."
        // Error message for invalid event start time input in dd/mm/yyyy format.
        static let optionalTimeError = "Enter date in format dd/mm/yyyy (e.g., 24/06/2025)."
        // Error message for invalid time to add input.
        static let timeToAddError = "Enter time in the format 'days:hours:minutes' (e.g., 1:03:45 for 1 day, 3 hours, 45 minutes)."

        // Error message for invalid event time input.
        static let invalidEventTimeMessage = "Invalid event time input"
        // Error message for invalid time to add input.
        static let invalidAddTimeMessage = "Invalid time to add input"
        // Error message for bad date value.
        static let badDate = "Bad date"
        // Error message when planet number is missing.
        static let missingPlanetNumber = "Planet Number Missing"
    }
}

