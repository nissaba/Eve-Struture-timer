//
//  DeleteEventButton.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//


import SwiftUI
import SwiftData

struct DeleteEventButton: View {
    @FocusedBinding(\.selectedEvent) private var selectedEvent
    @FocusedBinding(\.deleteRequested) private var deleteRequested

    var body: some View {
        Button("Delete Event", role: .destructive) {
            deleteRequested = true
        }
        .disabled(selectedEvent == nil)
    }
}
