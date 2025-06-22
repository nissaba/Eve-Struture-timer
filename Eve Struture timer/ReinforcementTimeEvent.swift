//
//  KillTimeEvent.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//


import SwiftUI
import SwiftData
import EventKit

/// A data model representing a reinforcement event in the game with relevant scheduling and location information.
/// This class stores details such as when the event was created, when it is due, its location, and whether it is defensive or offensive.
/// It also provides functionality to add the event to the user's calendar.
@Model
class ReinforcementTimeEvent: Identifiable {
    
    /// The date when the event was scheduled or created.
    var createdDate: Date
    
    /// The date when the reinforcement event is due.
    var dueDate: Date
    
    /// The name of the system where the event is taking place.
    var systemName: String
    
    /// The planet number associated with the event.
    var planet: Int8
    
    /// A flag indicating whether this is a defensive event (`true`) or an offensive event (`false`).
    var isDefence: Bool
    
    /// Initializes a new reinforcement time event.
    ///
    /// - Parameters:
    ///   - createdDate: The date when the event is scheduled (defaults to current date/time).
    ///   - dueDate: The date when the event will take place.
    ///   - systemName: The name of the system where the event occurs.
    ///   - planet: The planet number associated with the event.
    ///   - isDefence: A Boolean indicating whether the event is defensive (`true`) or offensive (`false`).
    init(createdDate: Date = Date(), dueDate: Date, systemName: String, planet: Int8, isDefence: Bool) {
        self.createdDate = createdDate
        self.dueDate = dueDate
        self.systemName = systemName
        self.planet = planet
        self.isDefence = isDefence
    }
    
    /// The remaining time interval until the event occurs.
    ///
    /// - Returns: The time interval in seconds from the current moment until the event's due date. Negative if the event is past due.
    var remainingTime: TimeInterval {
        return dueDate.timeIntervalSinceNow
    }
    
    /// A formatted string representation of the event's creation date.
    ///
    /// - Returns: A string formatted as `"dd/MM/yyyy HH:mm"` representing when the event was created.
    var createdDateString: String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/MM/yyyy HH:mm"
        return formater.string(from: createdDate)
    }
    
    /// Indicates whether the event's due date is in the past.
    ///
    /// - Returns: `true` if the event is past due, otherwise `false`.
    var isPastDue: Bool {
        return remainingTime < 0
    }
    
    /// Requests access and attempts to add the reinforcement event to the user's calendar.
    ///
    /// Handles permission requests for calendar access and creates the event if access is granted.
    func addToCalendar() {
        let store = EKEventStore()
       
        if #available(macOS 14, *) {
            store.requestFullAccessToEvents { [self, store] hasAccess, error in
                if hasAccess {
                    print("Access granted")
                    let calendar = store.defaultCalendarForNewEvents
                    guard let calendar = calendar else {
                        print("No default calendar available.")
                        return
                    }
                    self.createEvent(using: store, calendar: calendar)
                } else {
                    print("Calendar access denied: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        } else {
            store.requestAccess(to: .event) { [unowned self] granted, error in
                if granted {
                    let calendar = store.defaultCalendarForNewEvents
                    guard let calendar = calendar else {
                        print("No default calendar available.")
                        return
                    }
                    createEvent(using: store, calendar: calendar)
                } else {
                    print("Calendar access denied: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }

    /// Creates and saves a calendar event for the reinforcement using the specified calendar and event store.
    ///
    /// - Parameters:
    ///   - store: The `EKEventStore` instance used to save the event.
    ///   - calendar: The calendar in which the event should be added.
    ///
    /// This method sets the event title, start and end dates, notes, and calendar.
    /// It checks for calendar permissions before attempting to save.
    private func createEvent(using store: EKEventStore, calendar: EKCalendar) {
        let event = EKEvent(eventStore: store)
        event.title = "Reinforcement: \(self.systemName)"
        event.startDate = self.dueDate
        event.endDate = self.dueDate.addingTimeInterval(15 * 60)
        event.notes = "Planet \(self.planet)"
        event.calendar = calendar

        if !calendar.allowsContentModifications {
            print("Error: The calendar does not allow adding events.")
            return
        }
        print("Calendar: \(calendar.title), allows modifications: \(calendar.allowsContentModifications)")
        print("Start date: \(String(describing: event.startDate)), End date: \(String(describing: event.endDate))")

        do {
            try store.save(event, span: .thisEvent)
            print("Event added to calendar.")
        } catch {
            print("Failed to save event. Error: \(error). Possible causes: permissions not granted, invalid calendar, or invalid dates.")
        }
    }
    
    /// Prints debug information about all calendars available in the event store.
    ///
    /// This method lists each calendar's title, whether it allows modifications, and its type.
    static func debugPrintAllCalendars() {
        let store = EKEventStore()
        let calendars = store.calendars(for: .event)
        print("enumerating calendars:")
        for calendar in calendars {
            print("Calendar: \(calendar.title), Writable: \(calendar.allowsContentModifications), Type: \(calendar.type.rawValue)")
        }
    }
}

