//
//  EventRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-16.
//

import SwiftUI
import SwiftData
import AppKit

/// A view that displays information for a single reinforcement event.
/// Highlights the event if selected, and provides actions to add the event to the calendar or delete it.
struct EventRow: View {
    /// The Core Data model context used for CRUD operations.
    @Environment(\.modelContext) private var context
    /// The reinforcement event to display.
    let event: ReinforcementTimeEvent
    
    /// Binding to the currently selected event, used to highlight the selected row.
    @Binding var selectedEvent: ReinforcementTimeEvent?
    
    /// Closure called when the delete button is tapped.
    var onDelete: () -> Void
    
    /// State to control the display of calendar-related alerts.
    @State private var showingCalendarAlert = false
    
    /// Message displayed in the calendar alert.
    @State private var calendarAlertMessage = ""
    
    /// The main content and layout of the event row.
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
    
    /// A date formatter configured to display dates in UTC timezone.
    private var utcDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter
    }
    
    /// Returns the due date formatted as a local time string.
    private var localTimeString: String {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return formatter.string(from: event.dueDate)
    }
}

private extension EventRow {
    /// A view displaying the header information of the event including system name, planet, and type.
    var headerView: some View {
        HStack {
            Group{
                Text(event.systemName)
                    .fontWeight(.bold)
                    .font(.headline)
                    .strikethrough(event.isPastDue)
                if let info = event.locationInfo{
                    Text(" - Location \(info)")
                        .fontWeight(.regular)
                        .font(.headline)
                        .strikethrough(event.isPastDue)
                }
            }
            Spacer()
            Text(event.isDefence ? "Defence" : "Offence")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(event.isDefence ? Color.red : Color.orange)
        }
    }
    /// A view displaying event details such as due dates and action buttons for calendar and deletion.
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
                Task{
                 let success = await event.addToCalendar()
                    if success {
                        print("Event added to calendar")
                        //save and if error show an alert
                        do{
                           try context.save()
                        }catch {
                            calendarAlertMessage = "Failed to save event to calendar: \(error.localizedDescription)"
                            showingCalendarAlert = true
                        }
                    }
                }
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

/// SwiftUI preview for EventRow displaying a sample event.
#Preview {
    struct PreviewWrapper: View {
        @State private var selected: ReinforcementTimeEvent? = nil
        
        var body: some View {
            let event = ReinforcementTimeEvent(
                dueDate: Date().addingTimeInterval(3600 * 24),
                systemName: "Jita",
                locationInfo: "4",
                isDefence: false
            )
            
            EventRow(event: event, selectedEvent: $selected){
                
            }
                .frame(minWidth: 368)
        }
    }
    
    return PreviewWrapper()
}

