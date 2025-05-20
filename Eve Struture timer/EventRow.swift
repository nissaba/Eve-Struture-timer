//
//  EventRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-16.
//

import SwiftUI
import SwiftData

struct EventRow: View {
    let event: ReinforcementTimeEvent
    @Binding var selectedEvent: ReinforcementTimeEvent?
    
    var body: some View {
        
        ZStack() {
            RoundedRectangle(cornerRadius: 10)
                .fill(selectedEvent?.id == event.id ? Color.accentColor.opacity(0.15) : Color.clear)
            
            Grid(horizontalSpacing: 16, verticalSpacing: 8) {
                GridRow {
                    LabeledValueRow(label: "System:", value: event.systemName).frame(minWidth: 120, alignment: .leading)
                    LabeledValueRow(label: "Local Time:", value: formattedLocalDate(date: event.dueDate)).frame(minWidth: 120, alignment: .leading).strikethrough(event.isPastDue, pattern: .solid)
                    
                }
                GridRow {
                    LabeledValueRow(label: "Planet:", value: "\(event.planet)").frame(minWidth: 120, alignment: .leading)
                    LabeledValueRow(label: "EVE Time:", value: formattedDate(date: event.dueDate)).frame(minWidth: 120, alignment: .leading).strikethrough(event.isPastDue, pattern: .solid)
                    
                    
                }
            }
            .gridColumnAlignment(.leading)
            .padding(.horizontal)
            
        }
        .contentShape(Rectangle()) // 🟢 Makes whole cell respond to clicks
        .onTapGesture {
            selectedEvent = event // 🟢 Set selection on tap
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )
        .frame(minWidth: 384)
        .foregroundColor(event.isDefence ? Color.red : Color.orange)
    }
}

fileprivate func formattedDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    return formatter.string(from: date)
}

fileprivate func formattedLocalDate(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.timeZone = .current
    formatter.dateFormat = "dd/MM/yyyy HH:mm"
    return formatter.string(from: date)
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected: ReinforcementTimeEvent? = nil
        
        var body: some View {
            let event = ReinforcementTimeEvent(
                dueDate: Date().addingTimeInterval(3600 * 24),
                systemName: "Jita",
                planet: 4,
                isDefence: false
            )
            
            return EventRow(event: event, selectedEvent: $selected)
        }
    }
    
    return PreviewWrapper()
}
