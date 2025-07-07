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
    var location: String = "" {
        didSet { validatePlanetNumber() }
    }

    /// User input for event start time
    var eventStartTime: Date = Date()

    /// User input for additional time to add to the event. Validated on change.
    var duration: Duration = Duration() {
        didSet { validateTimeToAdd() }
    }

    /// Indicates if this is a defense timer event.
    var isDefenseTimer: Bool = false
    
    // MARK: - Published Validation Errors

    /// Validation error message (or nil) for the system name field.
    var systemNameError: String? = Constants.systemNameError

    /// Validation error message (or nil) for the planet number field.
    var planetNumberError: String? = Constants.planetNumberError

    /// Validation error message (or nil) for the duration (time to add) field.
    var timeToAddError: String? = nil


    // MARK: - Computed Validation State

    /// Returns true if all validation errors are nil.
    @ObservationIgnored var isAllValid: Bool {
        systemNameError == nil &&
        planetNumberError == nil
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
            location = event.locationInfo ?? ""
            eventStartTime = event.createdDate
            isDefenseTimer = event.isDefence

            let remainingTime = event.remainingTime

            if remainingTime > 0 {
                // Duration struct does not take seconds directly.
                // For now, set to zero duration.
                duration = Duration()
                // Optionally implement helper to convert seconds into days, hours, minutes later.
            } else {
                duration = Duration()
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
        if location.isEmpty {
            planetNumberError = Constants.planetNumberError
        } else {
            planetNumberError = nil
        }
    }

    /// Validates the duration and sets the error message.
    func validateTimeToAdd() {
        if duration.days == 0 && duration.hours == 0 && duration.minutes == 0 {
            timeToAddError = Constants.timeToAddError
        } else {
            timeToAddError = nil
        }
    }

    // MARK: - Actions

    /// Calculates the resulting event date/time based on user inputs.
    /// Updates resultText accordingly.
    func calculateFutureTime() {
        let finalDate = eventStartTime.addingTimeInterval(duration.timeInterval)
        resultText = formatDate(finalDate)
    }

    /// Persists the new or updated event based on form state.
    /// Validates necessary inputs before saving.
    func saveEvent() {
        guard !location.isEmpty else {
            resultText = Constants.missingPlanetNumber
            return
        }

        if let event = editingEvent {
            updateEvent(event, with: eventStartTime)
        } else if let existingEvent = fetchEvent(systemName: systemName, location: location) {
            updateEvent(existingEvent, with: eventStartTime)
        } else {
            createNewEvent(systemName: systemName,
                           location: location,
                           date: eventStartTime,
                           timeToAdd: duration,
                           isDefence: isDefenseTimer)
        }
    }

    // MARK: - Internal Logic

    /// Updates an existing event with new values.
    private func updateEvent(_ event: ReinforcementTimeEvent, with date: Date) {
        context.updateEvent(event,
                            newSystemName: systemName,
                            location: location,
                            newCreatedDate: date,
                            timeRemaining: 0, // Removed usage of duration.timeInterval
                            newIsDefence: isDefenseTimer)
    }

    /// Creates a new event with specified parameters.
    private func createNewEvent(systemName: String, location: String?, date: Date, timeToAdd: Duration, isDefence: Bool) {
        context.addEvent(systemName: systemName,
                         location: location,
                         createdDate: date,
                         timeInterval: duration.timeInterval,
                         isDefence: isDefence)
    }

    /// Fetches an existing event matching the given system name and planet.
    private func fetchEvent(systemName: String, location: String?) -> ReinforcementTimeEvent? {
        let predicate = #Predicate<ReinforcementTimeEvent> { event in
            event.systemName == systemName && event.locationInfo == location
        }
        let fetchDescriptor = FetchDescriptor<ReinforcementTimeEvent>(predicate: predicate)
        return try? context.fetch(fetchDescriptor).first
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

        // Error message for invalid system name input.
        static let systemNameError = "Only letters, numbers, spaces, and a single hyphen are allowed."
        // Error message for invalid planet number input.
        static let planetNumberError = "Enter struture location in system."
        // Error message for invalid time to add input.
        static let timeToAddError = "Duration must be greater than zero."

        // Error message for invalid event time input.
        static let invalidEventTimeMessage = "Invalid event time input"
        // Error message for invalid time to add input.
        static let invalidAddTimeMessage = "Invalid time to add input"
        // Error message for bad date value.
        static let badDate = "Bad date"
        // Error message when planet number is missing.
        static let missingPlanetNumber = "Structure location missing"
    }
}

// MARK: - Duration Extension for TimeInterval

extension Duration {
    var timeInterval: TimeInterval {
        TimeInterval(days * 86400 + hours * 3600 + minutes * 60)
    }
}
