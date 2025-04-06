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
    
    var body: some Scene {
        // Creates the main application window with a unique identifier.
        Window("Mercenary Den Ref Timers", id: "mainWindow") {
            // The main view displayed in the window.
            EventList()
        }
        // Sets the default size of the window.
        .defaultSize(width: 600, height: 400)
        // Initializes a data model container for the ReinforcementTimeEvent model.
        .modelContainer(for: ReinforcementTimeEvent.self)
        // Adds custom commands to the app's menu bar.
        .commands {
            CommandMenu("Events") {
                // A button in the menu to trigger the display of a sheet.
                ShowSheetButton()
                    .keyboardShortcut("E") // Keyboard shortcut for quick access.
            }
        }
    }
}

/// A view representing a button shown in the menu bar to open a sheet.
struct ShowSheetButton: View {
    /// Uses @FocusedValue to access a binding that controls sheet visibility.
    @FocusedValue(\.showSheet) private var showSheet
    
    var body: some View {
        Button {
            // Action triggered when the button is pressed.
            print("add") // For debugging purposes.
            showSheet?.wrappedValue = true // Set the sheet value to true to show it.
        } label: {
            Label("Show Sheet", systemImage: "eye")
        }
        // Disables the button if showSheet is not available in the current context.
        .disabled(showSheet == nil)
    }
}
