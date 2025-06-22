//
//  SelectionModel.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//

import Foundation

/// Tracks the currently selected event and provides functionality to delete it.
class SelectionModel: ObservableObject {
    /// The event currently selected by the user.
    @Published var selectedEvent: ReinforcementTimeEvent?
    
    /// Persistence layer used to perform operations (injected).
    var persistence: EventPersistence?

    /// Deletes the selected event from persistence and clears the selection.
    /// Should be used when the user wants to remove the currently selected event.
    func deleteSelectedEvent() {
        guard let event = selectedEvent else { return }
        persistence?.deleteEvent(event)
        selectedEvent = nil
    }
}

