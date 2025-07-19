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
    @Environment(\.modelContext) private var context
    @FocusedValue(\.selectedEvent) var selectedEvent
    
    @State private var showErrorAlert = false
    @State private var errorMessage: String? = nil
    
    var body: some View {
        Button {
            Task {
                let success = await selectedEvent?.wrappedValue?.addToCalendar() ?? false
                if !success {
                    errorMessage = "Failed to add event to calendar."
                    showErrorAlert = true
                } else {
                    do {
                        try context.save()
                    } catch {
                        errorMessage = "Failed to add event to calendar: \(error.localizedDescription)"
                        showErrorAlert = true
                    }
                }
            }
        } label: {
            Label("Add to Calendar", systemImage: "calendar")
        }
        .disabled(selectedEvent?.wrappedValue == nil)
        .alert("Error Adding to Calendar", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(errorMessage ?? "Unknown error.")
        })
    }
}

