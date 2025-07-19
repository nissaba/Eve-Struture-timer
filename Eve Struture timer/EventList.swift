import SwiftUI
import SwiftData

/// A view displaying a list of reinforcement time events, managing selection, edits, and deletions.
struct EventList: View {
    /// The Core Data model context used for CRUD operations.
    @Environment(\.modelContext) private var context
    /// The shared selection model environment object for managing selected event state.
    @EnvironmentObject var selectionModel: SelectionModel
    /// A query fetching reinforcement time events sorted by their due date.
    @Query(sort: \ReinforcementTimeEvent.dueDate) var events: [ReinforcementTimeEvent]
    /// The current color scheme of the device (light or dark mode).
    @Environment(\.colorScheme) var colorScheme
    /// The current date/time, updated every minute to refresh the UI.
    @State private var now = Date()
    /// The currently selected reinforcement time event, if any.
    @State private var selected: ReinforcementTimeEvent? = nil
    /// Controls the presentation state of the event form sheet.
    @State private var showForm = false
    /// Flags whether a delete action has been requested for the selected event.
    @State private var deleteRequested = false
    /// Controls the presentation of an error alert.
    @State private var showErrorAlert = false
    /// Holds the error message to display in the alert.
    @State private var errorMessage: String? = nil
    
    
    /// The main view body showing a navigation stack with a scrollable list of events.
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 12) {
                    let eventsSnapshot = events
                    ForEach(eventsSnapshot, id: \.self) { event in
                        eventCell(for: event)
                    }
                }
                .padding()
            }
            .background(
                colorScheme == .dark ? Color.black.opacity(0.3) : Color.white.opacity(0.6)
            )
            .navigationTitle("Reinforcement Timers")
            .toolbar {
                Button {
                    selected = nil
                    showForm = true
                } label: {
                    Label("Add Event", systemImage: "plus")
                }
            }
            .sheet(isPresented: $showForm) {
                EventFormView(isVisible: $showForm, context: context, selectedEvent: selected)
            }
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { newDate in
                now = newDate
            }
            .onChange(of: selected) { old, new in
                print("Selection changed: \(String(describing: new?.systemName))")
            }
            .onChange(of: deleteRequested) { _, newValue in
                guard newValue == true, let event = selected else { return }
                context.deleteEvent(event)
                event.deleteCalendarEvent()
                selected = nil
                deleteRequested = false
            }
            .onAppear(){
                selectionModel.persistence = context
            }
        }
        .focusedSceneValue(\.selectedEvent, $selected)
        .focusedSceneValue(\.showSheet, $showForm)
        .focusedSceneValue(\.deleteRequested, $deleteRequested)
        .alert("Error", isPresented: $showErrorAlert, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            if let errorMessage {
                Text(errorMessage)
            }
        })
        
    }
    
    /// Returns a view representing a single event cell with context menu and tap gestures.
    /// - Parameter event: The reinforcement time event to display in the cell.
    @ViewBuilder
    private func eventCell(for event: ReinforcementTimeEvent) -> some View {
        EventRow(event: event, selectedEvent: $selected){
            context.deleteEvent(event)
        }
            .contentShape(Rectangle())
            .onTapGesture {
                selected = event
            }
            .onTapGesture(count: 2) {
                selected = event
                showForm = true
            }
            .contextMenu {
                Button(action: {
                    selected = event
                    showForm = true
                }) {
                    Label("Edit", systemImage: "square.and.pencil")
                }
                Button(action: {
                    Task {
                        do {
                            let success = await event.addToCalendar()
                            if success {
                                try context.save()
                            }
                        } catch {
                            errorMessage = error.localizedDescription
                            showErrorAlert = true
                        }
                    }
                }) {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                }
                Button(role: .destructive, action: { context.deleteEvent(event) }) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

/// Extension providing example and sample reinforcement time events for preview and testing.
extension ReinforcementTimeEvent {
    /// An example reinforcement time event used as a template.
    static let example = ReinforcementTimeEvent(
        dueDate: Date().addingTimeInterval(3600),
        systemName: "Jita",
        locationInfo: "4",
        isDefence: false
    )
    
    /// An array of sample reinforcement time events for testing and previews.
    static let sampleItems: [ReinforcementTimeEvent] = [
        .example,
        ReinforcementTimeEvent(dueDate: Date().addingTimeInterval(-1800), systemName: "Amamake", locationInfo: "2",   isDefence: true),
        ReinforcementTimeEvent(dueDate: Date().addingTimeInterval(7200), systemName: "Rens", locationInfo: "3",  isDefence: false)
    ]
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ReinforcementTimeEvent.self, configurations: config)
    
    // Insertion manuelle des événements mock
    for item in ReinforcementTimeEvent.sampleItems {
        container.mainContext.insert(item)
    }
    
    return EventList()
        .modelContainer(container)
}
