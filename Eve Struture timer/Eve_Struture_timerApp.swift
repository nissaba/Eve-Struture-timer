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
    var body: some Scene {
        // Creates the main application window with a unique identifier.
        Window("Mercenary Den Ref Timers", id: "mainWindow") {
            // The main view displayed in the window.
            EventList()
                .frame(width: 400, height: 700)
                .environmentObject(selectionModel)
        }
        // Sets the default size of the window.
        .windowResizability(.contentSize)
        // Initializes a data model container for the ReinforcementTimeEvent model.
        .modelContainer(for: ReinforcementTimeEvent.self)
        // Adds custom commands to the app's menu bar.
        .commands {
            CommandMenu("Events") {
                // A button in the menu to trigger the display of a sheet.
                EditEventButton().keyboardShortcut("E") // Keyboard shortcut for quick access.
                AddEventToCalendarButton().keyboardShortcut("F")
                Divider()
                DeleteEventButton().keyboardShortcut("G")
                    .environmentObject(selectionModel)
            }
            
        }
    }
}









