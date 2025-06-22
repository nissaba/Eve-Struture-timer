//
//  EventRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-16.
//

import SwiftUI
import SwiftData
import AppKit

struct EventRow: View {
    let event: ReinforcementTimeEvent
    @Binding var selectedEvent: ReinforcementTimeEvent?
    var onDelete: () -> Void
    @State private var showingCalendarAlert = false
    @State private var calendarAlertMessage = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            detailsView
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.gray.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(selectedEvent?.id == event.id ? Color.accentColor : Color.gray.opacity(0.25), lineWidth: selectedEvent?.id == event.id ? 2 : 1)
        )
        .shadow(color: selectedEvent?.id == event.id ? Color.accentColor.opacity(0.3) : Color.black.opacity(0.10), radius: selectedEvent?.id == event.id ? 10 : 6, x: 0, y: 3)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedEvent = event
        }
        .animation(.spring(duration: 0.25), value: selectedEvent?.id)
        .alert(calendarAlertMessage, isPresented: $showingCalendarAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private var utcDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }
    
    private var localTimeString: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: event.dueDate)
    }
}

private extension EventRow {
    var headerView: some View {
        HStack {
            Group{
                Text(event.systemName)
                    .fontWeight(.bold)
                    .font(.headline)
                    .strikethrough(event.isPastDue)
                Text(" - Planet \(event.planet)")
                    .fontWeight(.regular)
                    .font(.headline)
                    .strikethrough(event.isPastDue)
            }
            Spacer()
            Text(event.isDefence ? "Defence" : "Offence")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(event.isDefence ? Color.red : Color.orange)
        }
    }
    var detailsView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Due: \(localTimeString)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("UTC: \(utcDateFormatter.string(from: event.dueDate))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                event.addToCalendar()
            } label: {
                Image(systemName: "calendar.badge.plus")
                    .font(.title3)
            }
            .buttonStyle(.borderless)
            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
                    .font(.title3)
            }
            .buttonStyle(.borderless)
        }
    }
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
            
            EventRow(event: event, selectedEvent: $selected){
                
            }
                .frame(minWidth: 368)
        }
    }
    
    return PreviewWrapper()
}
