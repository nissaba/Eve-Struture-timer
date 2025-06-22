//
//  EditEventButton.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//

import SwiftUI

/// A button that enables editing of the currently selected reinforcement event by presenting a sheet.
///
/// Uses focused values to access the selected event and sheet presentation state.
/// The button is disabled if no event is selected or if the sheet binding is unavailable.
/// Provides a keyboard shortcut (⌘E) for convenience.
struct EditEventButton: View {
    @FocusedValue(\.selectedEvent) private var selectedEvent
    @FocusedValue(\.showSheet) private var showSheet
    
    var body: some View {
        Button {
            print("edit")
            showSheet?.wrappedValue = true
        } label: {
            Label("Edit Event", systemImage: "pencil")
        }
        .keyboardShortcut("E", modifiers: [.command])
        .disabled(selectedEvent?.wrappedValue == nil || showSheet == nil)
    }
}

