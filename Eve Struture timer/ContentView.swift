//
//  ContentView.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

import SwiftUI
import SwiftData
import AppKit

struct ContentView: View { // User input for day
    
    @Environment(\.modelContext) private var context
    @State private var eventTimeString: String = "" // User input for event time (HH:mm)
    @State private var timeAddString: String = ""
    @State private var systemString: String = ""
    @State private var planetString: String = ""
    @State private var resultText: String = "Enter Data"
    @State private var calculatedDate: Date?
    @Binding var isVisible: Bool
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                
                TextField("System Name", text: $systemString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                TextField("Planet number", text: $planetString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                TextField("Event Time (HH:mm)", text: $eventTimeString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Time to Add (D:HH:MM)", text: $timeAddString)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onSubmit {
                        calculateFutureTime()
                    }
                
                // Output result in a non-editable TextField
                Text(resultText)
                    .padding()
                    .font(.title)
                    .contextMenu {
                        Button("Copy") {
                            let pasteboard = NSPasteboard.general
                            pasteboard.clearContents()
                            pasteboard.setString(resultText, forType: .string)
                        }
                    }
                
                HStack{
                    Button("Calculate") {
                        calculateFutureTime()
                    }
                    .padding()
                    Button("Save") {
                        saveData()
                        
                    }
                    .padding()
                }
                
            }
            
        }
        .padding()
        
    }
    
    func saveData(){
        //if planet exist update it, else save a new event
        guard let planetNumber = Int8(planetString) else {
            resultText = "Not Saved"
            return
        }
        
        guard let date = calculatedDate else {
            resultText = "Bad date"
            return
        }
        
        if let existingEvent = fetchEvent(systemName: systemString, planet: planetString) {
            // ✅ Update the existing event
            existingEvent.date = date
            existingEvent.systemName = systemString
            existingEvent.planet = planetNumber
            
            
        }else{
            let newEvent = KillTimeEvent(date: date, systemName: systemString, planet: planetNumber)
            context.insert(newEvent)
            
            
        }
        
        do {
            try context.save()
            print("Event saved successfully!")
        } catch {
            print("Failed to save event: \(error)")
        }
        
        self.isVisible = false
        
    }
    
    private func fetchEvent(systemName: String, planet: String) -> KillTimeEvent? {
        guard let pNumber = Int8(planet) else { return nil }
        
        let predicate = #Predicate<KillTimeEvent> { event in
            event.systemName == systemName && event.planet == pNumber
        }
        
        let fetchDescriptor = FetchDescriptor<KillTimeEvent>(predicate: predicate)
        
        do {
            return try context.fetch(fetchDescriptor).first  // ✅ Return the actual event
        } catch {
            print("Failed to fetch event: \(error.localizedDescription)")
            return nil
        }
    }
    
    func calculateFutureTime() {
        // Get the current date and time
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Extract current year and month
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)
        let day = calendar.component(.day, from: currentDate)
        var hour = calendar.component(.hour, from: currentDate)
        var minute = calendar.component(.minute, from: currentDate)
        // Convert the user-provided day and event time into integers
        
        
        let eventTimeComponents = eventTimeString.split(separator: ":")
        if(eventTimeComponents.count == 2){
            guard let iHour = Int(eventTimeComponents[0]),
                  let iMinute = Int(eventTimeComponents[1]),
                  hour >= 0, hour < 24, minute >= 0, minute < 60 else {
                resultText = "Invalid event time input"
                return
            }
            hour = iHour
            minute = iMinute
        }
        
        // Set up the start date (current month, year, and user-provided day and time)
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        
        guard let startDate = calendar.date(from: components) else {
            resultText = "Error setting start date"
            return
        }
        
        // Parse the time to add (format: D:HH:MM)
        let timeComponents = timeAddString.split(separator: ":")
        guard timeComponents.count == 3, let addDays = Int(timeComponents[0]), let addHours = Int(timeComponents[1]), let addMinutes = Int(timeComponents[2]) else {
            resultText = "Invalid time to add input"
            return
        }
        
        // Add days, hours, and minutes
        var finalDate = startDate
        finalDate = calendar.date(byAdding: .day, value: addDays, to: finalDate)!
        finalDate = calendar.date(byAdding: .hour, value: addHours, to: finalDate)!
        finalDate = calendar.date(byAdding: .minute, value: addMinutes, to: finalDate)!
        calculatedDate = finalDate
        
        // Format the result into a readable string (DD/MM/YYYY HH:mm)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        
        resultText = dateFormatter.string(from: finalDate)
    }
}

