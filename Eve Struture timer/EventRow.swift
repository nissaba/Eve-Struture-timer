//
//  EventRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-16.
//

import SwiftUI
import SwiftData

enum EventRowActionEnum {
    case edit
    case addToCalendar
    case delete
}


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
            
            Text(formattedDate(date: event.date))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(formattedLocalDate(date: event.date))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            
            Spacer()
            Menu {
                Button(action: { itemSelected(event, EventRowActionEnum.edit) }) {
                    Text("Edit")
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: { itemSelected(event, EventRowActionEnum.addToCalendar)}){
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

fileprivate func formattedDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    return dateFormatter.string(from: date)
}

fileprivate func formattedLocalDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone.current  // Uses the device's local time zone
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
    return dateFormatter.string(from: date)
}

