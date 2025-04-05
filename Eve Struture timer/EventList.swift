//
//  EventList.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//


import SwiftUI
import SwiftData
import EventKit

fileprivate struct CalanderEvent: Identifiable {
    let id: UUID = UUID()
    let title: String
    let date: Date
    let description: String
}


struct EventList: View{
    @Environment(\.modelContext) private var context
    @Query(sort: \ReinforcementTimeEvent.dueDate, order: .forward) private var items: [ReinforcementTimeEvent]
    @State private var showSheet = false
    @State private var selectedEvent: ReinforcementTimeEvent?
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    let titlePaddingRow: CGFloat = 8.0
    @State private var timer: Timer?
    
    
    
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
                    EventRow(event: $0) { item, actionType in
                        switch actionType {
                        case .edit:
                            selectedEvent = item
                        case .addToCalendar:
                            addToCalander(item)
                        case .delete:
                            deleteEvent(item)
                        }
                        
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
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage))
            }
            .onAppear {
                startTimer()
            }
            .onDisappear {
                timer?.invalidate()
            }
        }
    }
        
         func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                refreshEvents()
            }
        }
        
         func refreshEvents() {
            Task { @MainActor in
                try? context.save() // This will trigger SwiftData to re-evaluate queries
            }
        }
        
        func addToCalander(_ event: ReinforcementTimeEvent) {
            requestCalendarAccess(CalanderEvent(title: "Reinforcement Time Event",
                                                date: event.dueDate,
                                                description: "Mercenary Den needs your help"))
        }
        func deleteEvent(_ event: ReinforcementTimeEvent) {
            context.delete(event)
        }
        
        private func requestCalendarAccess(_ event: CalanderEvent) {
            let eventStore = EKEventStore()
            
            eventStore.requestWriteOnlyAccessToEvents() { (granted, error) in
                if granted && error == nil {
                    let calendarEvent = EKEvent(eventStore: eventStore)
                    calendarEvent.title = event.title
                    calendarEvent.startDate = event.date
                    calendarEvent.endDate = event.date.addingTimeInterval(3600)
                    calendarEvent.notes = event.description
                    calendarEvent.calendar = eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try eventStore.save(calendarEvent, span: .thisEvent)
                        alertTitle = "Event Added"
                        alertMessage = "The event has been successfully added to your calendar."
                        showAlert = true
                    } catch {
                        alertTitle = "Error"
                        alertMessage = "There was an error adding the event to your calendar."
                        showAlert = true
                    }
                } else {
                    alertTitle = "Error"
                    alertMessage = "Access to the calendar was denied."
                    showAlert = true
                }
            }
        }
    }
    
    
    
    struct Preview {
        
        let modelContainer: ModelContainer
        init() {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            do {
                modelContainer = try ModelContainer(for: ReinforcementTimeEvent.self, configurations: config)
            } catch {
                fatalError("Could not initialize ModelContainer")
            }
        }
        func addExamples(_ examples: [ReinforcementTimeEvent]) {
            
            Task { @MainActor in
                examples.forEach { example in
                    modelContainer.mainContext.insert(example)
                }
            }
            
        }
        
    }
    
    extension ReinforcementTimeEvent {
        static var sampleItems: [ReinforcementTimeEvent] {
            [
                ReinforcementTimeEvent(createdDate: Date(), dueDate: Date.init(timeIntervalSinceNow: 43234), systemName: "Jita", planet: 4, isDefence: true),
                ReinforcementTimeEvent(createdDate: Date(), dueDate: Date.init(timeIntervalSinceNow: 23442), systemName: "Amarr", planet: 8, isDefence: false)
            ]
        }
    }
    
    #Preview {
        let preview = Preview()
        
        preview.addExamples(ReinforcementTimeEvent.sampleItems)
        
        return EventList()
            .modelContainer(preview.modelContainer)
    }
