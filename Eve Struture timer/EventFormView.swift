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
        static let systemNamePlaceholder = "System Name"
        static let planetNumberPlaceholder = "Planet number"
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
        static let calculateButtonLabel = "Calculate"
        static let saveButtonLabel = "Save"
        static let timeStartEventValidationPattern = #"^$|^(\d{1,2}):([0-1]?\d|2[0-3]):([0-5]?\d)?$"#
        static let addTimeValidationPattern = #"^(0|1|2):([0-1]?[0-9]|2[0-3]):([0-5]?[0-9])$"#
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
    
    @State private var isEventStartTimeValid: Bool = true
    @State private var isTimeToAddValid: Bool = false
    
    var body: some View {
        VStack {
            inputFields
            resultView
            actionButtons
        }
        .padding()
    }
    
    private var inputFields: some View {
        VStack(alignment: .center) {
            TextField(Constants.systemNamePlaceholder, text: $systemName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField(Constants.planetNumberPlaceholder, text: $planetNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
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
                placeHolder: Constants.optionalEventStartPlaceholder,
                errorMessage: Constants.timeToAddError,
                validator: RegexValidator(pattern: Constants.addTimeValidationPattern)
            )
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
            Button(Constants.calculateButtonLabel, action: calculateFutureTime).padding()
            Button(Constants.saveButtonLabel, action: saveEvent).padding()
        }
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
        
        if let existingEvent = fetchEvent(systemName: systemName, planet: planet) {
            updateEvent(existingEvent, with: date)
        } else {
            createNewEvent(with: date, systemName: systemName, planet: planet)
        }
        
        isVisible = false
    }
    
    private func updateEvent(_ event: KillTimeEvent, with date: Date) {
        event.date = date
        event.systemName = systemName
        event.planet = Int8(planetNumber) ?? Constants.defaultPlanetValue
        saveContext()
    }
    
    private func createNewEvent(with date: Date, systemName: String, planet: Int8) {
        let newEvent = KillTimeEvent(date: date, systemName: systemName, planet: planet)
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
    
    private func fetchEvent(systemName: String, planet: Int8) -> KillTimeEvent? {
        let predicate = #Predicate<KillTimeEvent> { event in
            event.systemName == systemName && event.planet == planet
        }
        let fetchDescriptor = FetchDescriptor<KillTimeEvent>(predicate: predicate)
        
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

