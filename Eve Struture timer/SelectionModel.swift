//
//  SelectionModel.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//

import Foundation

class SelectionModel: ObservableObject {
    @Published var selectedEvent: ReinforcementTimeEvent?
    
    /// Persistence layer used to perform operations (injected).
        var persistence: EventPersistence?

        /// Deletes the selected event using the provided persistence logic.
        func deleteSelectedEvent() {
            guard let event = selectedEvent else { return }
            persistence?.deleteEvent(event)
            selectedEvent = nil
        }
}
