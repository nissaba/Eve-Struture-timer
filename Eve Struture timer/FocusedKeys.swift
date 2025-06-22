//
//  ShowPreviewKey.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-10.
//
import SwiftUI

/// A `FocusedValueKey` for exposing a binding controlling sheet visibility
/// via the focused values environment.
struct ShowSheetKey: FocusedValueKey {
    /// The associated value is a binding to a `Bool` indicating sheet visibility.
    typealias Value = Binding<Bool>
}

/// An extension on `FocusedValues` adding a focused binding to control sheet visibility.
/// Set this value in a parent view to propagate sheet visibility state to child views.
extension FocusedValues {
    /// A binding to control whether a sheet is shown, accessed via focused values.
    var showSheet: Binding<Bool>? {
        get { self[ShowSheetKey.self] }
        set { self[ShowSheetKey.self] = newValue }
    }
}

/// A `FocusedValueKey` for exposing a binding to the currently selected event
/// via the focused values environment.
struct SelectedEventKey: FocusedValueKey {
    /// The associated value is a binding to an optional `ReinforcementTimeEvent`.
    typealias Value = Binding<ReinforcementTimeEvent?>
}

/// An extension on `FocusedValues` adding a focused binding for the selected event.
/// This enables child views to read or update the currently selected event.
extension FocusedValues {
    /// A binding to the selected `ReinforcementTimeEvent`, accessed via focused values.
    var selectedEvent: Binding<ReinforcementTimeEvent?>? {
        get { self[SelectedEventKey.self] }
        set { self[SelectedEventKey.self] = newValue }
    }
}

/// A `FocusedValueKey` for exposing a binding indicating a delete request
/// via the focused values environment.
struct DeleteRequestKey: FocusedValueKey {
    /// The associated value is a binding to a `Bool` indicating a delete action request.
    typealias Value = Binding<Bool>
}

/// An extension on `FocusedValues` adding a focused binding for delete requests.
/// This allows child views to observe or trigger delete requests.
extension FocusedValues {
    /// A binding indicating whether a delete has been requested, accessed via focused values.
    var deleteRequested: Binding<Bool>? {
        get { self[DeleteRequestKey.self] }
        set { self[DeleteRequestKey.self] = newValue }
    }
}
