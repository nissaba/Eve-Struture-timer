//
//  DataModelPersistenceProtocol.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-04-04.
//

import Foundation
import SwiftData

protocol EventPersistence {
    func fetchEvents() -> [ReinforcementTimeEvent]
    func addEvent(systemName: String, planet: Int8, createdDate: Date, timeInterval: TimeInterval, isDefence: Bool)
    func updateEvent(_ event: ReinforcementTimeEvent, newSystemName: String?, newPlanet: Int8?, newCreatedDate: Date?, timeRemaining: TimeInterval?, newIsDefence: Bool?)
    func deleteEvent(_ event: ReinforcementTimeEvent)
}

extension ModelContext: EventPersistence {
    func fetchEvents() -> [ReinforcementTimeEvent] {
        do {
            let sort: SortDescriptor<ReinforcementTimeEvent> = SortDescriptor(\ReinforcementTimeEvent.dueDate)
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
        let newEvent = ReinforcementTimeEvent(createdDate: createdDate, dueDate: dueDate, systemName: systemName, planet: planet, isDefence: isDefence)
        insert(newEvent)
        saveChanges()
    }

    func updateEvent(_ event: ReinforcementTimeEvent, newSystemName: String? = nil, newPlanet: Int8? = nil, newCreatedDate: Date? = nil, timeRemaining: TimeInterval? = nil, newIsDefence: Bool? = nil) {
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
        if let timeRemaining = timeRemaining{
            let dueDate = event.createdDate.addingTimeInterval(timeRemaining)
            event.dueDate = dueDate
        }
        saveChanges()
    }

    func deleteEvent(_ event: ReinforcementTimeEvent) {
        delete(event)
        saveChanges()
    }

    private func saveChanges() {
        do {
            try save()
        } catch {
            print("Save failed: \(error)")
        }
    }
}
