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
    @Query private var items: [ReinforcementTimeEvent]
    @State private var showSheet = false
    @State private var selectedEvent: ReinforcementTimeEvent?
    let titlePaddingRow: CGFloat = 8.0
    
    var body: some View{
        NavigationStack{
            VStack(alignment: .leading){
                HStack(alignment: .bottom){
                    Text("System")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Planet")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Eve Time")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Local Time")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    Text("Actions")
                }.padding([.top, .leading, .trailing], titlePaddingRow)
                List(items){
                    EventRow(event: $0) { item in
                        selectedEvent = item
                    }
                }
                .listStyle(.bordered)
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
        let container = try ModelContainer(for: ReinforcementTimeEvent.self, configurations: .init(isStoredInMemoryOnly: true))
        return EventList()
            .modelContainer(container)
    } catch {
        return Text("Failed to create preview: \(error.localizedDescription)")
    }
}
