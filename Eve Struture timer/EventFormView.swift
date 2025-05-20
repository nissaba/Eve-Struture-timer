//
//  ContentView.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-07.
//

// EventFormView.swift

import SwiftUI
import SwiftData

struct EventFormView: View {

    // MARK: - Bindings
    @Binding var isVisible: Bool

    // MARK: - ViewModel
    @StateObject private var viewModel: EventFormViewModel

    // MARK: - Init
    init(
        isVisible: Binding<Bool>,
        context: ModelContext,
        selectedEvent: ReinforcementTimeEvent? = nil
    ) {
        _isVisible = isVisible
        _viewModel = StateObject(wrappedValue: EventFormViewModel(context: context, editingEvent: selectedEvent))
    }

    // MARK: - View Body
    var body: some View {
        VStack {
            inputFields
            resultView
            actionButtons
        }
        .onChange(of: viewModel.isAllValid) { _, newValue in
            if newValue {
                viewModel.calculateFutureTime()
            }
        }
        .frame(width: Constants.formWidth, height: Constants.formHeight)
        .padding()
    }

    private var inputFields: some View {
        VStack(alignment: .center, spacing: Constants.fieldSpacing) {
            ValidationTextField(
                text: $viewModel.systemName,
                label: Constants.systemNameLabel,
                isValid: $viewModel.isSystemNameValid,
                placeHolder: Constants.systemNamePlaceholder,
                errorMessage: Constants.systemNameError,
                validator: RegexValidator(pattern: Constants.systemNameValidationPattern)
            )

            ValidationTextField(
                text: $viewModel.planetNumber,
                label: Constants.planetNumberLabel,
                isValid: $viewModel.isPlanetNumberValid,
                placeHolder: Constants.planetNumberPlaceholder,
                errorMessage: Constants.planetNumberError,
                validator: RegexValidator(pattern: Constants.planetNumberValidationPattern)
            )

            ValidationTextField(
                text: $viewModel.eventStartTime,
                label: Constants.optionalStartTimeLabel,
                isValid: $viewModel.isEventStartTimeValid,
                placeHolder: Constants.optionalEventStartPlaceholder,
                errorMessage: Constants.optionalEventStartError,
                validator: RegexValidator(pattern: Constants.timeStartEventValidationPattern)
            )

            ValidationTextField(
                text: $viewModel.timeToAdd,
                label: Constants.timeToAddLabel,
                isValid: $viewModel.isTimeToAddValid,
                placeHolder: Constants.timeToAddPlaceholder,
                errorMessage: Constants.timeToAddError,
                validator: RegexValidator(pattern: Constants.addTimeValidationPattern)
            )

            Toggle(isOn: $viewModel.isDefenseTimer) {
                Text(Constants.defenseToggleLabel)
            }
            .padding(.top, Constants.toggleTopPadding)
        }
    }

    private var resultView: some View {
        Text(viewModel.resultText)
            .font(.title)
            .contextMenu {
                Button(Constants.copyButtonLabel) {
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(viewModel.resultText, forType: .string)
                }
            }
    }

    private var actionButtons: some View {
        HStack {
            Spacer()
            Button(Constants.saveButtonLabel, action: {
                viewModel.saveEvent()
                isVisible = false
            })
            Button(Constants.cancelButtonLabel, action: {
                isVisible = false
            })
            Spacer()
        }
    }
}

// MARK: - Constants

private extension EventFormView {
    enum Constants {
        static let formWidth: CGFloat = 300
        static let formHeight: CGFloat = 400
        static let fieldSpacing: CGFloat = 4
        static let toggleTopPadding: CGFloat = 8

        static let systemNameLabel = "System Name"
        static let systemNamePlaceholder = "Jita"
        static let systemNameError = "System name must not be empty"
        static let systemNameValidationPattern = "^.+$"

        static let planetNumberLabel = "Planet Number"
        static let planetNumberPlaceholder = "8"
        static let planetNumberError = "Planet number must be a positive integer"
        static let planetNumberValidationPattern = "^[1-9]\\d*$"

        static let optionalStartTimeLabel = "From Date (optional)"
        static let optionalEventStartPlaceholder = "Optional Event Start Time (HH:mm)"
        static let optionalEventStartError = "Expected HH:mm or empty"
        static let timeStartEventValidationPattern = "^$|^(0?[0-9]|1[0-9]|2[0-3]):([0-5][0-9])$"

        static let timeToAddLabel = "Timer remaining to event"
        static let timeToAddPlaceholder = "Time to add D:HH:MM"
        static let timeToAddError = "Expected D:HH:MM"
        static let addTimeValidationPattern = "^[01]:(\\d|0\\d|1\\d|2[0-3]):(\\d|[0-5]\\d)$"

        static let defenseToggleLabel = "Is defence timer"

        static let copyButtonLabel = "Copy"
        static let saveButtonLabel = "Save"
        static let cancelButtonLabel = "Cancel"
    }
}


#Preview {
    let container = try! ModelContainer(for: ReinforcementTimeEvent.self)
    return EventFormView(isVisible: .constant(true), context: container.mainContext)
}
