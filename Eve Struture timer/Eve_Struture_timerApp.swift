//
//  Eve_Struture_timerApp.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

import SwiftUI
import SwiftData

/// Main entry point of the application.
/// Sets up the main window scene with the title "Mercenary Den Ref Timers".
@main
struct MyApp: App {
    @StateObject private var selectionModel = SelectionModel()
    @State private var showingAbout = false
    
    var body: some Scene {
        Window("Mercenary Den Ref Timers", id: "mainWindow") {
            EventList()
                .frame(width: 400, height: 700)
                .environmentObject(selectionModel)
                .sheet(isPresented: $showingAbout) {
                    AboutThisAppView(onClose: { showingAbout = false })
                }
        }
        .windowResizability(.contentSize)
        .modelContainer(for: ReinforcementTimeEvent.self)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About This App") {
                    showingAbout = true
                }
            }
            
            CommandMenu("Events") {
                EditEventButton().keyboardShortcut("E") // Keyboard shortcut for quick access.
                AddEventToCalendarButton().keyboardShortcut("F")
                Divider()
                DeleteEventButton().keyboardShortcut("G")
            }
        }
    }
}
