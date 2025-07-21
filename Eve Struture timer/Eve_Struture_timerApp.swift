//
//  Eve_Struture_timerApp.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

import SwiftData
import SwiftUI

/// Main entry point of the application.
/// Sets up the main window scene with the title "Mercenary Den Ref Timers".
@main
struct MyApp: App {
    @StateObject private var selectionModel = SelectionModel()
    @State private var showingAbout = false
    @State private var showingHelp = false

    var body: some Scene {
        Window("Eve Structure Timer", id: "mainWindow") {
            EventList()
                .frame(width: 400, height: 700)
                .sheet(isPresented: $showingAbout) {
                    AboutThisAppView(onClose: { showingAbout = false })
                }
                .sheet(isPresented: $showingHelp){
                    HelpView(closeAction: {showingHelp = false})
                }
        }
        .environmentObject(selectionModel)
        .windowResizability(.contentSize)
        .modelContainer(for: ReinforcementTimeEvent.self)
        //.commandsRemoved()
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About This App") {
                    showingAbout = true
                }
            }
            CommandGroup(replacing: .help) {
                Button("Eve Structure Timer Help") {
                    showingHelp = true
                }
                .keyboardShortcut("?", modifiers: .command)
            }

            CommandMenu("Events") {
                EditEventButton().keyboardShortcut("E")  // Keyboard shortcut for quick access.
                AddEventToCalendarButton().keyboardShortcut("F")
                Divider()
                DeleteEventButton().keyboardShortcut("G")
            }
        }
    }
}
