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
    @State private var selectedEvent: KillTimeEvent?
    
    var body: some View{
        NavigationStack{
            VStack{
                Text("Number of Events: \(items.count)")
                List{
                    ForEach(items){item in
                        EventRow(event: item) { item in
                            selectedEvent = item
                        }
                    }
                }
            }
            .frame(width: 400, height: 500)
            .focusedSceneValue(\.showSheet, $showSheet)
            .navigationTitle("Event List")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showSheet.toggle() }) {
                        Label("Add Event", systemImage: "plus")
                    }
                }
            }
            .onChange(of: selectedEvent) { _, newValue in
                if newValue != nil {
                    showSheet = true
                }
            }
            .onChange(of: showSheet, { oldValeu , newValue in
                if newValue == false {
                    selectedEvent = nil
                }
            })
            .sheet(isPresented: $showSheet) {
                EventFormView(isVisible: $showSheet, selectedEvent: selectedEvent)
            }
        }
    }
    
}






#Preview {
    do {
        let container = try ModelContainer(for: KillTimeEvent.self, configurations: .init(isStoredInMemoryOnly: true))
        return EventList()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
