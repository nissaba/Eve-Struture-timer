//
//  Eve_Struture_timerApp.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

import SwiftUI

@main
struct MyApp: App {
    
    var body: some Scene {
        Window("Mercenary Den Ref Timers", id: "mainWindow") {
            EventList()
        }.defaultSize(width: 600, height: 400)
            .modelContainer(for: KillTimeEvent.self)
            .commands {
                CommandMenu("Events") {
                    ShowSheetButton()
                        .keyboardShortcut("E")
                }
            }
    }
}

struct ShowSheetButton: View {
    @FocusedValue(\.showSheet) private var showSheet
    
    var body: some View {
        Button {
            print("add")
            showSheet?.wrappedValue = true
        } label: {
            Label("Show Sheet", systemImage: "eye")
        }
        .disabled(showSheet == nil)
    }
}
