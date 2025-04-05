//
//  ContentView.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

import SwiftUI
import SwiftData
import AppKit

struct EventFormView: View {
    @Environment(\.modelContext) private var context
    @Binding var isVisible: Bool
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
    var editingEvent: ReinforcementTimeEvent?
    
    
    var isAllValid: Bool {
        print(" isSystemNameValid: \(isSystemNameValid)\n isPlanetNumberValid: \(isPlanetNumberValid)\n isEventStartTimeValid: \(isEventStartTimeValid)\n isTimeToAddValid: \(isTimeToAddValid)\n")
        return isSystemNameValid && isEventStartTimeValid && isTimeToAddValid && isPlanetNumberValid
    }
    
    init(isVisible: Binding<Bool>, selectedEvent: ReinforcementTimeEvent? = nil) {
        _isVisible = isVisible
        self.editingEvent = selectedEvent
        if let event = selectedEvent {
            _systemName = State(initialValue: event.systemName)
            _planetNumber = State(initialValue: "\(event.planet)")
            _fromDate = State(initialValue: event.createdDate)
            _isDefenseTimer = State(initialValue: event.isDefence)
            
            // Calculate time remaining
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
    
    private var actionButtons: some View {
        HStack {
            Spacer()
            Button(Constants.saveButtonLabel, action: saveEvent)
            Button(Constants.cancelButtonLabel, action: cancelAction)
            Spacer()
        }
    }
    
    private func cancelAction(){
        isVisible = false
    }
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
    
    private func timeInterval(from formattedString: String) -> TimeInterval? {
        let components = formattedString.split(separator: ":").map { String($0) }
        
        guard components.count == 3,
              let days = Int(components[0]),
              let hours = Int(components[1]),
              let minutes = Int(components[2]) else {
            return nil
        }
        
        let totalSeconds = TimeInterval(days * 86_400 + hours * 3_600 + minutes * 60)
        return totalSeconds
    }
    
    private func updateEvent(_ event: ReinforcementTimeEvent, with date: Date) {
        
        guard let timeDelta = timeInterval(from: timeToAdd) else {
            return
        }
        context.updateEvent(event,
                            newSystemName: systemName,
                            newPlanet: Int8(planetNumber),
                            newCreatedDate: date,
                            timeRemaining: timeDelta,
                            newIsDefence: isDefenseTimer)
    }
    
    private func createNewEvent(systemName: String, planet: Int8, date: Date, timeToAdd: String, isDefence: Bool) {
        guard let timeTo = timeInterval(from: timeToAdd) else{
            return
        }
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
    
    private func calculateFutureTime() {
        guard let startDate = createStartDate() else {
            resultText = Constants.invalidEventTimeMessage
            return
        }
        
        guard let timeOffset = parseTimeOffset() else {
            resultText = Constants.invalidAddTimeMessage
            return
        }
        
        let finalDate = Calendar.current.date(byAdding: timeOffset, to: startDate) ?? startDate
        fromDate = finalDate
        
        resultText = formatDate(finalDate)
    }
    
    private func createStartDate() -> Date? {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let eventComponents = eventStartTime.split(separator: ":").compactMap { Int($0) }
        
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: currentDate)
        
        if eventComponents.count == 2 {
            components.hour = eventComponents.first
            components.minute = eventComponents.last
        }
        
        return calendar.date(from: components)
    }
    
    private func parseTimeOffset() -> DateComponents? {
        let timeComponents = timeToAdd.split(separator: ":").compactMap { Int($0) }
        guard timeComponents.count == 3 else { return nil }
        
        return DateComponents(day: timeComponents[0], hour: timeComponents[1], minute: timeComponents[2])
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC") //"UTC" will not change not adding to constants
        formatter.dateFormat = Constants.dateFormatString
        return formatter.string(from: date)
    }
}

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
