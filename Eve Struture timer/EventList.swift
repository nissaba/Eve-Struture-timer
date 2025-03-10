//
//  EventList.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//


import SwiftUI
import SwiftData    

struct EventList: View{
    @Environment(\.modelContext) private var context
    @Query private var items: [KillTimeEvent]
    @State private var showSheet = false
    
    var body: some View{
        VStack{
            Text("Number of Events: \(items.count)")
            List{
                ForEach(items){item in
                    HStack{
                        Text(item.systemName)   
                        Text("\(item.planet)")
                        Text("\(formattedDate(date: item.date))")
                    }
                }
            }
        }
        .focusedSceneValue(\.showSheet, $showSheet)
        .sheet(isPresented: $showSheet) {
            ContentView(isVisible: $showSheet)
        }
        
    }
    
}



func formattedDate(date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
  
    return dateFormatter.string(from: date)
}
