//
//  DataModelPersistenceProtocol.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-04-04.
//

import Foundation
import SwiftData

/// A protocol defining persistence operations for `ReinforcementTimeEvent` objects.
protocol EventPersistence {
    
    /// Fetches all reinforcement time events, sorted by due date.
    func fetchEvents() -> [ReinforcementTimeEvent]
    
    /// Adds a new reinforcement time event.
    /// - Parameters:
    ///   - systemName: The name of the system where the event takes place.
    ///   - planet: The planet number (1-8).
    ///   - createdDate: The date the event was created.
    ///   - timeInterval: Time interval until the event is due.
    ///   - isDefence: A boolean indicating whether the event is defensive.
    func addEvent(systemName: String, planet: Int8, createdDate: Date, timeInterval: TimeInterval, isDefence: Bool)
    
    /// Updates an existing reinforcement time event.
    /// - Parameters:
    ///   - event: The event to update.
    ///   - newSystemName: Optional new system name.
    ///   - newPlanet: Optional new planet number.
    ///   - newCreatedDate: Optional new creation date.
    ///   - timeRemaining: Optional new time remaining (used to recalculate due date).
    ///   - newIsDefence: Optional new defensive status.
    func updateEvent(_ event: ReinforcementTimeEvent,
                     newSystemName: String?,
                     newPlanet: Int8?,
                     newCreatedDate: Date?,
                     timeRemaining: TimeInterval?,
                     newIsDefence: Bool?)
    
    /// Deletes a reinforcement time event.
    /// - Parameter event: The event to delete.
    func deleteEvent(_ event: ReinforcementTimeEvent)
}

/// Conforms `ModelContext` to the `EventPersistence` protocol,
/// enabling database operations for `ReinforcementTimeEvent`.
extension ModelContext: EventPersistence {
    
    func fetchEvents() -> [ReinforcementTimeEvent] {
        do {
            let sort: SortDescriptor<ReinforcementTimeEvent> = SortDescriptor(\.dueDate)
            let descriptor = FetchDescriptor<ReinforcementTimeEvent>(sortBy: [sort])
            return try fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
            return []
        }
    }

    func addEvent(systemName: String, planet: Int8, createdDate: Date, timeInterval: TimeInterval, isDefence: Bool) {
        var dueDate = createdDate
        dueDate.addTimeInterval(timeInterval)
        let newEvent = ReinforcementTimeEvent(
            createdDate: createdDate,
            dueDate: dueDate,
            systemName: systemName,
            planet: planet,
            isDefence: isDefence
        )
        insert(newEvent)
        saveChanges()
    }

    func updateEvent(_ event: ReinforcementTimeEvent,
                     newSystemName: String? = nil,
                     newPlanet: Int8? = nil,
                     newCreatedDate: Date? = nil,
                     timeRemaining: TimeInterval? = nil,
                     newIsDefence: Bool? = nil) {
        
        if let newSystemName = newSystemName {
            event.systemName = newSystemName
        }
        if let newPlanet = newPlanet {
            event.planet = newPlanet
        }
        if let newDate = newCreatedDate {
            event.createdDate = newDate
        }
        if let newIsDefence = newIsDefence {
            event.isDefence = newIsDefence
        }
        if let timeRemaining = timeRemaining {
            event.dueDate = event.createdDate.addingTimeInterval(timeRemaining)
        }
        
        saveChanges()
    }

    func deleteEvent(_ event: ReinforcementTimeEvent) {
        delete(event)
        saveChanges()
    }

    /// Saves all changes in the current context, printing errors if save fails.
    private func saveChanges() {
        do {
            try save()
        } catch {
            print("Save failed: \(error)")
        }
    }
}
