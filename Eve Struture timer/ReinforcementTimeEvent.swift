//
//  KillTimeEvent.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//


import SwiftUI
import SwiftData

/// Represents a reinforcement event with a scheduled date, system location, and event type.
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
    /// - Parameters:
    ///   - createdDate: The date when the event is scheduled (defaults to now).
    ///   - dueDate: The date when the event will take place.
    ///   - systemName: The name of the system where the event occurs.
    ///   - planet: The planet number associated with the event.
    ///   - isDefence: Whether the event is defensive (`true`) or offensive (`false`).
    init(createdDate: Date = Date(), dueDate: Date, systemName: String, planet: Int8, isDefence: Bool) {
        self.createdDate = createdDate
        self.dueDate = dueDate
        self.systemName = systemName
        self.planet = planet
        self.isDefence = isDefence
    }

    /// The remaining time until the event happens.
    /// - Returns: The time interval between now and the due date. If negative, the event is past due.
    var remainingTime: TimeInterval {
        return dueDate.timeIntervalSinceNow
    }

    /// A formatted string representation of the event's creation date.
    ///
    /// - Returns: A string formatted as `"dd/MM/yyyy HH:mm"` (e.g., `"04/04/2025 14:30"`).
    var createdDateString: String {
        let formater = DateFormatter()
        formater.dateFormat = "dd/MM/yyyy HH:mm"
        return formater.string(from: createdDate)
    }
    
    /// Indicates whether the event is past due.
    /// - Returns: `true` if the event's due date is in the past, otherwise `false`.
    var isPastDue: Bool {
        return remainingTime < 0
    }
}
