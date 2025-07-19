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
    var locationInfo: String?
    
    /// A flag indicating whether this is a defensive event (`true`) or an offensive event (`false`).
    var isDefence: Bool
    
    /// A id to a event that was created in the calendar
    var calendarEventUUID: String?
    
    /// Initializes a new reinforcement time event.
    ///
    /// - Parameters:
    ///   - createdDate: The date when the event is scheduled (defaults to current date/time).
    ///   - dueDate: The date when the event will take place.
    ///   - systemName: The name of the system where the event occurs.
    ///   - planet: The planet number associated with the event.
    ///   - isDefence: A Boolean indicating whether the event is defensive (`true`) or offensive (`false`).
    init(createdDate: Date = Date(), dueDate: Date, systemName: String, locationInfo: String?, isDefence: Bool) {
        self.createdDate = createdDate
        self.dueDate = dueDate
        self.systemName = systemName
        self.locationInfo = locationInfo
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
    /// This async function handles permission requests for calendar access and creates the event if access is granted.
    /// - Returns: A Boolean indicating whether the event was successfully added to the calendar.
    func addToCalendar() async -> Bool {
        let store = EKEventStore()
        
        do {
            let hasAccess: Bool
            if #available(macOS 14, *) {
                hasAccess = try await withCheckedThrowingContinuation { continuation in
                    store.requestFullAccessToEvents { granted, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            } else {
                hasAccess = try await withCheckedThrowingContinuation { continuation in
                    store.requestAccess(to: .event) { granted, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: granted)
                        }
                    }
                }
            }
            
            guard hasAccess else {
                print("Calendar access denied.")
                return false
            }
            
            guard let calendar = store.defaultCalendarForNewEvents else {
                print("No default calendar available.")
                return false
            }
            
            let success = createEvent(using: store, calendar: calendar)
            if success {
                print("Event added to calendar.")
            }
            return success
            
        } catch {
            print("Failed to get calendar access: \(error.localizedDescription)")
            return false
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
    /// - Returns: `true` if the event was successfully saved, otherwise `false`.
    private func createEvent(using store: EKEventStore, calendar: EKCalendar) -> Bool {
        let event = EKEvent(eventStore: store)
        event.title = "Reinforcement: \(self.systemName)"
        event.startDate = self.dueDate
        event.endDate = self.dueDate.addingTimeInterval(15 * 60)
        if let info = self.locationInfo {
            event.notes = "Location: \(info)"
        }
        event.calendar = calendar

        if !calendar.allowsContentModifications {
            print("Error: The calendar does not allow adding events.")
            return false
        }
        print("Calendar: \(calendar.title), allows modifications: \(calendar.allowsContentModifications)")
        print("Start date: \(String(describing: event.startDate)), End date: \(String(describing: event.endDate))")

        do {
            try store.save(event, span: .thisEvent)
            self.calendarEventUUID = event.eventIdentifier
            
            return true
        } catch {
            print("Failed to save event. Error: \(error). Possible causes: permissions not granted, invalid calendar, or invalid dates.")
            return false
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
    
    /// Updates the event in the user's calendar if `calendarEventUUID` is set.
    ///
    /// This method will fetch the event using its identifier and update its fields to reflect the current object's state.
    func updateCalendarEvent() {
        guard let uuid = calendarEventUUID else {
            print("No calendarEventUUID set; cannot update event.")
            return
        }
        let store = EKEventStore()
        // macOS 14 and later: requestFullAccessToEvents, otherwise requestAccess(to:)
        let accessHandler: (Bool, Error?) -> Void = { [self] granted, error in
            if granted {
                if let event = store.event(withIdentifier: uuid) {
                    event.title = "Reinforcement: \(self.systemName)"
                    event.startDate = self.dueDate
                    event.endDate = self.dueDate.addingTimeInterval(15 * 60)
                    if let info = self.locationInfo {
                        event.notes = "Location: \(info)"
                    } else {
                        event.notes = nil
                    }
                    do {
                        try store.save(event, span: .thisEvent)
                        print("Event updated in calendar.")
                    } catch {
                        print("Failed to update event. Error: \(error)")
                    }
                } else {
                    print("No event found in calendar with identifier: \(uuid)")
                }
            } else {
                print("Calendar access denied: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        if #available(macOS 14, *) {
            store.requestFullAccessToEvents(completion: accessHandler)
        } else {
            store.requestAccess(to: .event, completion: accessHandler)
        }
    }
    
    /// Deletes the calendar event associated with this reinforcement event, if `calendarEventUUID` is set.
    ///
    /// Requests permission to access the calendar, then removes the event by its identifier.
    func deleteCalendarEvent() {
        guard let uuid = calendarEventUUID else {
            print("No calendarEventUUID set; cannot delete event.")
            return
        }
        let store = EKEventStore()
        let accessHandler: (Bool, Error?) -> Void = { granted, error in
            if granted {
                if let event = store.event(withIdentifier: uuid) {
                    do {
                        try store.remove(event, span: .thisEvent)
                        print("Event deleted from calendar.")
                    } catch {
                        print("Failed to delete event. Error: \(error)")
                    }
                } else {
                    print("No event found in calendar with identifier: \(uuid)")
                }
            } else {
                print("Calendar access denied: \(error?.localizedDescription ?? "unknown error")")
            }
        }
        if #available(macOS 14, *) {
            store.requestFullAccessToEvents(completion: accessHandler)
        } else {
            store.requestAccess(to: .event, completion: accessHandler)
        }
    }
}
