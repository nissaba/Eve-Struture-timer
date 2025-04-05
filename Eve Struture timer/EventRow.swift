//
//  EventRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-16.
//

import SwiftUI
import SwiftData

/// Represents the possible user actions on a reinforcement time event row.
enum EventRowActionEnum {
    case edit
    case addToCalendar
    case delete
}

/// A single row view that displays a reinforcement event and presents a contextual menu for actions.
///
/// This view displays the system name, planet number, and both UTC and local due dates of a `ReinforcementTimeEvent`.
/// It also provides a menu to trigger `edit`, `add to calendar`, and `delete` actions.
///
/// - Parameters:
///   - event: The `ReinforcementTimeEvent` instance to display.
///   - itemSelected: A closure that is called when a user selects an action from the row's menu.
///     It provides the selected event and the chosen `EventRowActionEnum`.
struct EventRow: View {
    let event: ReinforcementTimeEvent
    var itemSelected: (_ item: ReinforcementTimeEvent, _ actionType: EventRowActionEnum) -> Void

    var body: some View {
        HStack {
            Text(event.systemName)
                .strikethrough(event.isPastDue, color: .red)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("\(event.planet)")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(formattedDate(date: event.dueDate))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(formattedLocalDate(date: event.dueDate))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Menu {
                Button(action: { itemSelected(event, .edit) }) {
                    Text("Edit")
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: { itemSelected(event, .addToCalendar) }) {
                    Text("Add to Calendar")
                }
                
                Button(action: { itemSelected(event, .delete) }) {
                    Text("Delete")
                }
                .buttonStyle(BorderlessButtonStyle())
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            .frame(alignment: .center)
            .padding(.horizontal)
        }
        .foregroundColor(event.isDefence ? Color.red : Color.orange)
    }
}

/// Formats a given date to a string using UTC time zone.
///
/// - Parameter date: The `Date` to format.
/// - Returns: A string representation in `"dd/MM/yyyy HH:mm"` format.
fileprivate func formattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    return dateFormatter.string(from: date)
}

/// Formats a given date to a string using the device’s local time zone.
///
/// - Parameter date: The `Date` to format.
/// - Returns: A string representation in `"dd/MM/yyyy HH:mm"` format.
fileprivate func formattedLocalDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    return dateFormatter.string(from: date)
}

