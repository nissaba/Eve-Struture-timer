import SwiftUI
import SwiftData

struct EventList: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var selectionModel: SelectionModel
    @Query(sort: \ReinforcementTimeEvent.dueDate) var events: [ReinforcementTimeEvent]
    @Environment(\.colorScheme) var colorScheme
    @State private var now = Date()
    @State private var selected: ReinforcementTimeEvent? = nil
    @State private var showForm = false
    @State private var deleteRequested = false
    
    
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
        
    }
    
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
                    event.addToCalendar()
                }) {
                    Label("Add to Calendar", systemImage: "calendar.badge.plus")
                }
                Button(role: .destructive, action: { context.deleteEvent(event) }) {
                    Label("Delete", systemImage: "trash")
                }
            }
    }
}

extension ReinforcementTimeEvent {
    static let example = ReinforcementTimeEvent(
        dueDate: Date().addingTimeInterval(3600),
        systemName: "Jita",
        planet: 4,
        isDefence: false
    )
    
    static let sampleItems: [ReinforcementTimeEvent] = [
        .example,
        ReinforcementTimeEvent(dueDate: Date().addingTimeInterval(-1800), systemName: "Amamake", planet: 2,   isDefence: true),
        ReinforcementTimeEvent(dueDate: Date().addingTimeInterval(7200), systemName: "Rens", planet: 3,  isDefence: false)
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
