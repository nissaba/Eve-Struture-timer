//
//  ContentView.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

import SwiftUI
import SwiftData
import AppKit

/// A SwiftUI view for creating or editing a `ReinforcementTimeEvent`.
/// Allows the user to input the system name, planet number, event start time,
/// and a timer offset to calculate the final event time.
struct EventFormView: View {
    // MARK: - Environment
    
    /// The model context used to interact with SwiftData.
    @Environment(\.modelContext) private var context
    
    // MARK: - Bindings
    
    /// Controls whether this form is visible.
    @Binding var isVisible: Bool
    
    // MARK: - State
    
    @State private var eventStartTime: String = ""
    @State private var timeToAdd: String = ""
    @State private var systemName: String = ""
    @State private var planetNumber: String = ""
    @State private var resultText: String = "Enter Data"
    @State private var fromDate: Date?
    @State private var isSystemNameValid: Bool = false
    @State private var isEventStartTimeValid: Bool = true
    @State private var isTimeToAddValid: Bool = false
    @State private var isPlanetNumberValid: Bool = false
    @State private var isDefenseTimer: Bool = false
    
    /// An optional event used when editing an existing event.
    var editingEvent: ReinforcementTimeEvent?
    @State private var selectedEvent: ReinforcementTimeEvent?
    
    /// Returns `true` if all user inputs are valid.
    var isAllValid: Bool {
        print(" isSystemNameValid: \(isSystemNameValid)\n isPlanetNumberValid: \(isPlanetNumberValid)\n isEventStartTimeValid: \(isEventStartTimeValid)\n isTimeToAddValid: \(isTimeToAddValid)\n")
        return isSystemNameValid && isEventStartTimeValid && isTimeToAddValid && isPlanetNumberValid
    }
    
    // MARK: - Initializer
    
    init(isVisible: Binding<Bool>, selectedEvent: ReinforcementTimeEvent? = nil) {
        _isVisible = isVisible
        self.editingEvent = selectedEvent
        
        if let event = selectedEvent {
            _systemName = State(initialValue: event.systemName)
            _planetNumber = State(initialValue: "\(event.planet)")
            _fromDate = State(initialValue: event.createdDate)
            _isDefenseTimer = State(initialValue: event.isDefence)
            
            let remainingTime = event.remainingTime
            let secondsPerDay = 86_400
            let secondsPerHour = 3_600
            let secondsPerMinutes = 60
            
            if remainingTime > 0 {
                let days = Int(remainingTime) / secondsPerDay
                let hours = (Int(remainingTime) % secondsPerDay) / secondsPerHour
                let minutes = (Int(remainingTime) % secondsPerHour) / secondsPerMinutes
                let formattedTime = String(format: "%d:%02d:%02d", days, hours, minutes)
                _timeToAdd = State(initialValue: formattedTime)
            } else {
                _timeToAdd = State(initialValue: "00:00:00")
            }
        }
    }
    
    // MARK: - View Body
    
    var body: some View {
        VStack {
            inputFields
            resultView
            actionButtons
        }
        .onChange(of: isAllValid) { _, newValue in
            if newValue {
                calculateFutureTime()
            }
        }
        .frame(width: 300, height: 400)
        .padding()
    }
    
    /// Input fields for system name, planet number, event time and duration.
    private var inputFields: some View {
        VStack(alignment: .center, spacing: 4) {
            ValidationTextField(
                text: $systemName,
                label: "System Name",
                isValid: $isSystemNameValid,
                placeHolder: Constants.systemNamePlaceholder,
                errorMessage: Constants.systemNameError,
                validator: RegexValidator(pattern: Constants.systemNameValidationPattern)
            )
            
            ValidationTextField(
                text: $planetNumber,
                label: "Planet Number",
                isValid: $isPlanetNumberValid,
                placeHolder: Constants.planetNumberPlaceholder,
                errorMessage: Constants.planetNumberError,
                validator: RegexValidator(pattern: Constants.planetNumberValidationPattern)
            )
            
            ValidationTextField(
                text: $eventStartTime,
                label: "From Date (optional)",
                isValid: $isEventStartTimeValid,
                placeHolder: Constants.optionalEventStartPlaceholder,
                errorMessage: Constants.optionalEventStartError,
                validator: RegexValidator(pattern: Constants.timeStartEventValidationPattern)
            )
            
            ValidationTextField(
                text: $timeToAdd,
                label: "Timer remaining to event",
                isValid: $isTimeToAddValid,
                placeHolder: Constants.timeToAddPlaceholder,
                errorMessage: Constants.timeToAddError,
                validator: RegexValidator(pattern: Constants.addTimeValidationPattern)
            )
            
            Toggle(isOn: $isDefenseTimer) {
                Text("Is defence timer")
            }
            .padding(.top, 8)
        }
    }
    
    /// Displays the computed future date.
    private var resultView: some View {
        Text(resultText)
            .font(.title)
            .contextMenu {
                Button(Constants.copyButtonLabel) {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(resultText, forType: .string)
                }
            }
    }
    
    /// Action buttons to save or cancel the form.
    private var actionButtons: some View {
        HStack {
            Spacer()
            Button(Constants.saveButtonLabel, action: saveEvent)
            Button(Constants.cancelButtonLabel, action: cancelAction)
            Spacer()
        }
    }
    
    /// Dismisses the form.
    private func cancelAction(){
        isVisible = false
    }
    
    /// Validates inputs and saves or updates the event.
    private func saveEvent() {
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
        }
        else if let existingEvent = fetchEvent(systemName: systemName, planet: planet) {
            updateEvent(existingEvent, with: date)
        } else {
            createNewEvent(systemName: systemName,
                           planet: planet,
                           date: date,
                           timeToAdd: timeToAdd,
                           isDefence: isDefenseTimer)
        }
        
        isVisible = false
    }
    
    /// Parses a "D:HH:MM" string into a `TimeInterval`.
    private func timeInterval(from formattedString: String) -> TimeInterval? {
        let components = formattedString.split(separator: ":").map { String($0) }
        guard components.count == 3,
              let days = Int(components[0]),
              let hours = Int(components[1]),
              let minutes = Int(components[2]) else {
            return nil
        }
        return TimeInterval(days * 86_400 + hours * 3_600 + minutes * 60)
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
    
    /// Creates a new event.
    private func createNewEvent(systemName: String, planet: Int8, date: Date, timeToAdd: String, isDefence: Bool) {
        guard let timeTo = timeInterval(from: timeToAdd) else { return }
        context.addEvent(systemName: systemName,
                         planet: planet,
                         createdDate: date,
                         timeInterval: timeTo,
                         isDefence: isDefence)
    }
    
    /// Fetches an existing event by system name and planet number.
    private func fetchEvent(systemName: String, planet: Int8) -> ReinforcementTimeEvent? {
        let predicate = #Predicate<ReinforcementTimeEvent> { event in
            event.systemName == systemName && event.planet == planet
        }
        let fetchDescriptor = FetchDescriptor<ReinforcementTimeEvent>(predicate: predicate)
        return try? context.fetch(fetchDescriptor).first
    }
    
    /// Calculates the final event date by adding the offset to the start date.
    private func calculateFutureTime() {
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
    
    /// Builds a date from the current day and the optional input time.
    private func createStartDate() -> Date? {
        let calendar = Calendar.current
        let currentDate = Date()
        let eventComponents = eventStartTime.split(separator: ":").compactMap { Int($0) }
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
        
        guard eventComponents.count == 2 else { return currentDate}
        
        components.hour = eventComponents.first
        components.minute = eventComponents.last
        
        return calendar.date(from: components)
    }
    
    /// Parses the D:HH:MM string into `TimeInterval`.
    private func parseTimeOffset() -> TimeInterval? {
        let timeComponents = timeToAdd.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == 3 else { return nil }

        let days = timeComponents[0]
        let hours = timeComponents[1]
        let minutes = timeComponents[2]

        return TimeInterval(days * 86400 + hours * 3600 + minutes * 60)
    }
    
    /// Formats a `Date` into a UTC string.
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = Constants.dateFormatString
        return formatter.string(from: date)
    }
}

// MARK: - Constants

extension EventFormView {
    private enum Constants {
        static let enterData = "Enter Information"
        static let systemNamePlaceholder = "Jita"
        static let systemNameError = "System name must not be empty"
        static let planetNumberPlaceholder = "8"
        static let planetNumberError = "Planet number must be a positive integer"
        static let optionalEventStartPlaceholder = "Optional Event Start Time (HH:mm)"
        static let optionalEventStartError = "Expected DD:HH:MM or empty"
        static let timeToAddPlaceholder = "Time to add D:HH:MM"
        static let timeToAddError = "Expected D:HH:MM"
        static let invalidEventTimeMessage = "Invalid event time input"
        static let invalidAddTimeMessage = "Invalid time to add input"
        static let dateFormatString = "dd/MM/yyyy HH:mm"
        static let badDate = "Bad date"
        static let missingPlanetNumber = "Planet Number Missing"
        static let copyButtonLabel = "Copy"
        static let cancelButtonLabel = "Cancel"
        static let saveButtonLabel = "Save"
        static let timeStartEventValidationPattern = #"^$|^(0?[0-9]|1[0-9]|2[0-3]):([0-5][0-9])$"#
        static let addTimeValidationPattern = #"^[01]:(\d|0\d|1\d|2[0-3]):(\d|[0-5]\d)$"#
        static let planetNumberValidationPattern = #"^[1-9]\d*$"#
        static let systemNameValidationPattern = #"^.+$"#
        static let defaultPlanetValue: Int8 = 0
    }
}

#Preview {
    EventFormView(isVisible: .constant(true))
}
