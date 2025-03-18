//
//  EventRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-16.
//

import SwiftUI
import SwiftData


struct EventRow: View {
    @Environment(\.modelContext) private var context
    let event: KillTimeEvent
    var itemSelected: (_ item: KillTimeEvent) -> Void

    var body: some View {
        HStack {
            Text(event.systemName)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("\(event.planet)")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(formattedDate(date: event.date))
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button(action: { itemSelected(event) }) {
                Image(systemName: "pencil")
            }
            .buttonStyle(BorderlessButtonStyle())

            Button(action: { deleteEvent() }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }

    private func deleteEvent() {
        context.delete(event)
    }
}

fileprivate func formattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    return dateFormatter.string(from: date)
}
