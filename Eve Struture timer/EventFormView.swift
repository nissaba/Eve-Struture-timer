//
//  ContentView.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

// EventFormView.swift

import SwiftUI
import SwiftData
import AppKit

struct EventFormView: View {
    // MARK: - Environment
    
    // MARK: - Bindings
    @Binding var isVisible: Bool
    
    // MARK: - State
    @State private var viewModel: EventFormViewModel
    
    // MARK: - Init
    init(isVisible: Binding<Bool>, context: ModelContext, selectedEvent: ReinforcementTimeEvent? = nil) {
        self._isVisible = isVisible
        self._viewModel = State(initialValue: EventFormViewModel(context: context, editingEvent: selectedEvent))
    }
    
    var body: some View {
        VStack {
            inputFields
            resultView
            actionButtons
        }
        .onChange(of: viewModel.timeToAdd) { _,_ in
            if viewModel.isAllValid {
                viewModel.calculateFutureTime()
            }
        }
        .onChange(of: viewModel.eventStartTime) { _,_ in
            if viewModel.isAllValid {
                viewModel.calculateFutureTime()
            }else{
                print("not valid")
            }
        }
        .frame(width: Constants.formWidth, height: Constants.formHeight)
        .padding()
    }
    
    private var inputFields: some View {
        VStack(alignment: .center, spacing: 4) {
            ValidationTextField(
                text: $viewModel.systemName,
                errorMessage: $viewModel.systemNameError,
                placeHolder: Constants.systemNamePlaceholder,
                label: Constants.systemNameLabel,
            ){
                
            }
            
            ValidationTextField(
                text: $viewModel.planetNumber,
                errorMessage: $viewModel.planetNumberError,
                placeHolder: Constants.planetPlaceholder,
                label: Constants.planetLabel,
            ){}
            
            ValidationTextField(
                text: $viewModel.eventStartTime,
                errorMessage: $viewModel.eventStartTimeError,
                placeHolder: Constants.startTimePlaceholder,
                label: Constants.startTimeLabel,
            ){}
            
            ValidationTextField(
                text: $viewModel.timeToAdd,
                errorMessage: $viewModel.timeToAddError,
                placeHolder: Constants.durationPlaceholder,
                label: Constants.durationLabel,
            ){}
            
            Toggle(isOn: $viewModel.isDefenseTimer) {
                Text(Constants.toggleLabel)
            }
            .padding(.top, Constants.fieldTopPadding)
        }
    }
    
    private var resultView: some View {
        Text(viewModel.resultText)
            .font(.title)
            .contextMenu {
                Button(Constants.copyButton) {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(viewModel.resultText, forType: .string)
                }
            }
    }
    
    private var actionButtons: some View {
        HStack {
            Spacer()
            Button(Constants.saveButton, action: saveEvent)
            Button(Constants.cancelButton, action: cancelAction)
            Spacer()
        }
    }
    
    private func cancelAction() {
        isVisible = false
    }
    
    private func saveEvent() {
        guard viewModel.isAllValid else {
            return
        }
        
        viewModel.saveEvent()
        
        isVisible = false
    }
}

// MARK: - Constants



extension EventFormView {
    struct Constants {
        static let optionalTimeOffsetPattern = #"^$|^(?:\d{1,2}h\d{1,2}m|\d{1,2}h|\d{1,2}m)$"#
        
        static let systemNameLabel = "System Name"
        static let systemNamePlaceholder = "Jita"
        
        static let planetLabel = "Planet Number"
        static let planetPlaceholder = "8"
        
        static let startTimeLabel = "From Date (optional)"
        static let startTimePlaceholder = "Optional start time (e.g., 20h12m)"
        
        static let durationLabel = "Timer remaining to event"
        static let durationPlaceholder = "Time to add (e.g., 1j2h30m)"
        
        static let toggleLabel = "Is defence timer"
        
        static let copyButton = "Copy"
        static let saveButton = "Save"
        static let cancelButton = "Cancel"
        static let formWidth: CGFloat = 300
        static let formHeight: CGFloat = 400
        static let invalidInput = "Invalid input."
        static let planetNumberPattern = "^[1-9]\\d*$"
        static let fieldTopPadding: CGFloat = 8
    }
}

#Preview {
    let context = try! ModelContainer(for: ReinforcementTimeEvent.self).mainContext
    
    let mockEvent = ReinforcementTimeEvent(
        dueDate: Date().addingTimeInterval(3600 * 24), // +1 day
        systemName: "Jita",
        planet: 4,
        isDefence: false
    )
    
    EventFormView(
        isVisible: .constant(true), context: context, selectedEvent: mockEvent
    )
    
}
