//
//  EditEventButton.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//

import SwiftUI

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
