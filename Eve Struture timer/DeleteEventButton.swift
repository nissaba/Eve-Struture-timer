//
//  DeleteEventButton.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//


import SwiftUI
import SwiftData

/// A destructive button that requests deletion of the currently selected reinforcement event.
///
/// Uses focused bindings to access the currently selected event and a delete request flag.
/// The button is disabled if no event is selected. When pressed, it sets the delete request flag to true.
struct DeleteEventButton: View {
    @FocusedValue(\.selectedEvent) private var selectedEvent
    @FocusedBinding(\.deleteRequested) private var deleteRequested

    var body: some View {
        Button("Delete Event", role: .destructive) {
            deleteRequested = true
        }
        .disabled(selectedEvent?.wrappedValue == nil)
    }
}

