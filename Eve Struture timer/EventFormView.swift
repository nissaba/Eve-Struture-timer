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
            }
        }
        .frame(width: Constants.formWidth, height: Constants.formHeight)
        .padding()
    }

    private var inputFields: some View {
        VStack(alignment: .center, spacing: 4) {
            ValidationTextField(
                text: $viewModel.systemName,
                label: Constants.systemNameLabel,
                isValid: $viewModel.isSystemNameValid,
                placeHolder: Constants.systemNamePlaceholder,
                errorMessage: Constants.systemNameError,
                validator: RegexValidator(pattern: ".+")
            )

            ValidationTextField(
                text: $viewModel.planetNumber,
                label: Constants.planetLabel,
                isValid: $viewModel.isPlanetNumberValid,
                placeHolder: Constants.planetPlaceholder,
                errorMessage: Constants.planetError,
                validator: RegexValidator(pattern: Constants.planetNumberPattern)
            )

            ValidationTextField(
    text: $viewModel.eventStartTime,
    label: Constants.startTimeLabel,
    isValid: $viewModel.isEventStartTimeValid,
    placeHolder: Constants.startTimePlaceholder,
    errorMessage: Constants.startTimeError,
    validator: RegexValidator(pattern: Constants.optionalTimeOffsetPattern)
)

            ValidationTextField(
                text: $viewModel.timeToAdd,
                label: Constants.durationLabel,
                isValid: $viewModel.isTimeToAddValid,
                placeHolder: Constants.durationPlaceholder,
                errorMessage: Constants.durationError,
                validator: RegexValidator(pattern: EventFormViewModel.Constants.durationPattern)
            )

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
        guard let planet = Int8(viewModel.planetNumber),
              let baseDate = viewModel.fromDate,
              let duration = EventFormViewModel.parseFlexibleDuration(viewModel.timeToAdd) else {
            viewModel.resultText = Constants.invalidInput
            return
        }

        if let event = viewModel.editingEvent {
            viewModel.context.updateEvent(event,
                                newSystemName: viewModel.systemName,
                                newPlanet: planet,
                                newCreatedDate: baseDate,
                                timeRemaining: duration,
                                newIsDefence: viewModel.isDefenseTimer)
        } else {
            viewModel.context.addEvent(systemName: viewModel.systemName,
                             planet: planet,
                             createdDate: baseDate,
                             timeInterval: duration,
                             isDefence: viewModel.isDefenseTimer)
        }

        isVisible = false
    }
}

// MARK: - Constants

// MARK: - Constants

extension EventFormView {
    struct Constants {
        static let optionalTimeOffsetPattern = "^$|^(?:(\\d{1,2})h)?(?:(\\d{1,2})m)?$"

        static let systemNameLabel = "System Name"
        static let systemNamePlaceholder = "Jita"
        static let systemNameError = "System name must not be empty"

        static let planetLabel = "Planet Number"
        static let planetPlaceholder = "8"
        static let planetError = "Planet number must be a positive integer"

        static let startTimeLabel = "From Date (optional)"
        static let startTimePlaceholder = "Optional start time (e.g., 20h12m)"
        static let startTimeError = "Expected time like 20h12m or empty"

        static let durationLabel = "Timer remaining to event"
        static let durationPlaceholder = "Time to add (e.g., 1j2h30m)"
        static let durationError = "Expected duration like 1j2h30m"

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
