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
        ZStack(alignment: .leading) {
            if selectedEvent?.id == event.id {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.accentColor.opacity(0.2))
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.accentColor, lineWidth: 2)
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.gray.opacity(0.12), .gray.opacity(0.12) ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 18)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
            VStack(alignment: .leading, spacing: 12) {
                locationView
                Divider()
                localTimeView
                Divider()
                eveTimeVView
            }
            .padding(20)
        }
        .frame(minWidth: 368)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedEvent = event
        }
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
        .foregroundStyle(selectedEvent?.id == event.id ? Color.accentColor : (event.isDefence ? Color.red : Color.orange))
        .animation(.spring(duration: 0.25), value: selectedEvent?.id)
    }
    
    private var eveTimeVView: some View {
        HStack {
            Image(systemName: "timer")
                .foregroundStyle(.secondary)
            Text("EVE Time:")
                .fontWeight(.semibold)
            Text(formattedDate(date: event.dueDate))
                .strikethrough(event.isPastDue, pattern: .solid)
                .foregroundStyle(event.isPastDue ? .secondary : .primary)
            Spacer()
        }
    }
    
    private var localTimeView: some View {
        HStack {
            Image(systemName: "clock.fill")
                .foregroundStyle(.secondary)
            Text("Local Time:")
                .fontWeight(.semibold)
            Text(formattedLocalDate(date: event.dueDate))
                .strikethrough(event.isPastDue, pattern: .solid)
                .foregroundStyle(event.isPastDue ? .secondary : .primary)
            Spacer()
        }
    }
    private var locationView: some View {
        HStack {
            Image("solar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24, alignment: .center)
                .foregroundStyle(.secondary)
            Text("System:")
                .fontWeight(.semibold)
            Text(event.systemName)
                .foregroundStyle(.primary)
            Divider()
            Image(systemName: "circle.fill")
                .foregroundStyle(.secondary)
            Text("Planet:")
                .fontWeight(.semibold)
            Text("\(event.planet)")
                .foregroundStyle(.primary)
            Spacer()
            Spacer()
        }
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
