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
    private enum Constants {
        static let enterData = "Enter Data"
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
    
    @Environment(\.modelContext) private var context
    @Binding var isVisible: Bool
    @State private var eventStartTime: String = ""
    @State private var timeToAdd: String = ""
    @State private var systemName: String = ""
    @State private var planetNumber: String = ""
    @State private var resultText: String = "Enter Data"
    @State private var calculatedDate: Date?
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
            _calculatedDate = State(initialValue: event.date)
            _isDefenseTimer = State(initialValue: event.isDefence)
            
            // Calculate time remaining
            let now = Date()
            let remainingTime = event.date.timeIntervalSince(now)
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
        .frame(width: 300, height: 350)
        .padding()
        
    }
    
    private var inputFields: some View {
        VStack(alignment: .center) {
            ValidationTextField(
                text: $systemName,
                isValid: $isSystemNameValid,
                placeHolder: Constants.systemNamePlaceholder,
                errorMessage: Constants.systemNameError,
                validator: RegexValidator(pattern: Constants.systemNameValidationPattern)
            )
            
            ValidationTextField(
                text: $planetNumber,
                isValid: $isPlanetNumberValid,
                placeHolder: Constants.planetNumberPlaceholder,
                errorMessage: Constants.planetNumberError,
                validator: RegexValidator(pattern: Constants.planetNumberValidationPattern)
            )
            
            ValidationTextField(
                text: $eventStartTime,
                isValid: $isEventStartTimeValid,
                placeHolder: Constants.optionalEventStartPlaceholder,
                errorMessage: Constants.optionalEventStartError,
                validator: RegexValidator(pattern: Constants.timeStartEventValidationPattern)
            )
            
            ValidationTextField(
                text: $timeToAdd,
                isValid: $isTimeToAddValid,
                placeHolder: Constants.timeToAddPlaceholder,
                errorMessage: Constants.timeToAddError,
                validator: RegexValidator(pattern: Constants.addTimeValidationPattern)
            )
            
            Toggle(isOn: $isDefenseTimer) {
                Text("Is defence timer")
            }
        }
    }
    
    private var resultView: some View {
        Text(resultText)
            .padding()
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
        
        guard let date = calculatedDate else {
            resultText = Constants.badDate
            return
        }
        
        if let event = editingEvent {
            updateEvent(event, with: date)
        }
        else if let existingEvent = fetchEvent(systemName: systemName, planet: planet) {
            updateEvent(existingEvent, with: date)
        } else {
            createNewEvent(with: date, systemName: systemName, planet: planet)
        }
        
        isVisible = false
    }
    
    private func updateEvent(_ event: ReinforcementTimeEvent, with date: Date) {
        event.date = date
        event.systemName = systemName
        event.isDefence = isDefenseTimer
        event.planet = Int8(planetNumber) ?? Constants.defaultPlanetValue
        saveContext()
    }
    
    private func createNewEvent(with date: Date, systemName: String, planet: Int8) {
        let newEvent = ReinforcementTimeEvent(date: date, systemName: systemName, planet: planet, isDefence: isDefenseTimer)
        context.insert(newEvent)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
            print("Event saved successfully!")
        } catch {
            print("Failed to save event: \(error)")
        }
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
        calculatedDate = finalDate
        
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

#Preview {
    EventFormView(isVisible: .constant(true))
}
