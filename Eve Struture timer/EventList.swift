//
//  EventList.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//


import SwiftUI
import SwiftData
import EventKit

/// A simple struct representing an event to be added to the calendar.
fileprivate struct CalendarEvent: Identifiable {
    let id: UUID = UUID()
    let title: String
    let date: Date
    let description: String
}

/// The main view displaying a list of reinforcement events and allowing actions on them.
struct EventList: View {
    @Environment(\.modelContext) private var context

    /// The list of reinforcement time events fetched via SwiftData.
    @Query(sort: \ReinforcementTimeEvent.dueDate, order: .forward) private var items: [ReinforcementTimeEvent]

    /// Whether the sheet for adding/editing an event is shown.
    @State private var showSheet = false

    /// The event currently selected for editing.
    @State private var selectedEvent: ReinforcementTimeEvent?

    /// Whether the alert is currently visible.
    @State private var showAlert = false

    /// The title for the alert dialog.
    @State private var alertTitle = ""

    /// The message for the alert dialog.
    @State private var alertMessage = ""

    /// Timer to refresh events every 60 seconds.
    @State private var timer: Timer?

    /// Padding for the row title section.
    let titlePaddingRow: CGFloat = 8.0

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack(alignment: .bottom) {
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
                }
                .padding([.top, .leading, .trailing], titlePaddingRow)

                List(items) { item in
                    EventRow(event: item) { item, actionType in
                        switch actionType {
                        case .edit:
                            selectedEvent = item
                        case .addToCalendar:
                            addToCalendar(item)
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
            .onChange(of: showSheet) { _, newValue in
                if !newValue {
                    selectedEvent = nil
                }
            }
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

    /// Starts a timer to refresh events every 60 seconds.
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            refreshEvents()
        }
    }

    /// Forces SwiftData to re-evaluate queries and refresh the list.
    func refreshEvents() {
        Task { @MainActor in
            try? context.save()
        }
    }

    /// Prepares and requests calendar access to add a `ReinforcementTimeEvent`.
    /// - Parameter event: The event to be added.
    func addToCalendar(_ event: ReinforcementTimeEvent) {
        requestCalendarAccess(
            CalendarEvent(
                title: "Reinforcement Time Event",
                date: event.dueDate,
                description: "Mercenary Den needs your help"
            )
        )
    }

    /// Deletes a `ReinforcementTimeEvent` from the context.
    /// - Parameter event: The event to delete.
    func deleteEvent(_ event: ReinforcementTimeEvent) {
        context.delete(event)
    }

    /// Requests access to the user's calendar and adds the provided event.
    /// - Parameter event: The `CalendarEvent` to add to the default calendar.
    private func requestCalendarAccess(_ event: CalendarEvent) {
        let eventStore = EKEventStore()

        eventStore.requestWriteOnlyAccessToEvents { granted, error in
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
