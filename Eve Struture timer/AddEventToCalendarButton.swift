//
//  AddEventToCalendarButton.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//

import SwiftUI
import SwiftData

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
