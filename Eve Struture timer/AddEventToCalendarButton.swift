//
//  AddEventToCalendarButton.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//

import SwiftUI
import SwiftData

/// A button that adds the currently selected reinforcement event to the user's calendar.
///
/// Uses the focused value from the environment to access the selected event.
/// The button is disabled if no event is selected.
/// When pressed, it calls the event's `addToCalendar()` method.
struct AddEventToCalendarButton: View {
    @FocusedValue(\.selectedEvent) private var selectedEvent

    var body: some View {
        Button {
            selectedEvent?.wrappedValue?.addToCalendar()
        } label: {
            Label("Add to Calendar", systemImage: "calendar")
        }
        .disabled(selectedEvent?.wrappedValue == nil)
    }
}

