//
//  ShowPreviewKey.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-10.
//
import SwiftUI

/// A key for accessing a `Binding<Bool>` in the focused values environment.
/// 
/// This is used to propagate and access a sheet visibility state
/// through SwiftUI's focused value system.
struct ShowSheetKey: FocusedValueKey {
    /// The type of value associated with this key: a binding to a Boolean.
    typealias Value = Binding<Bool>
}

/// An extension to `FocusedValues` that adds a computed property `showSheet`,
/// allowing views to read and write a binding controlling whether a sheet is shown.
///
/// Usage:
/// - Set this in a parent view using `.focusedSceneValue(\.showSheet, $isSheetVisible)`
/// - Read it in child views with `@FocusedValue(\.showSheet)`
extension FocusedValues {
    /// A focused binding to control the visibility of a sheet.
    var showSheet: Binding<Bool>? {
        get { self[ShowSheetKey.self] }
        set { self[ShowSheetKey.self] = newValue }
    }
}


struct SelectedEventKey: FocusedValueKey {
    typealias Value = Binding<ReinforcementTimeEvent?>
}

extension FocusedValues {
    var selectedEvent: Binding<ReinforcementTimeEvent?>? {
        get { self[SelectedEventKey.self] }
        set { self[SelectedEventKey.self] = newValue }
    }
}

struct DeleteRequestKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var deleteRequested: Binding<Bool>? {
        get { self[DeleteRequestKey.self] }
        set { self[DeleteRequestKey.self] = newValue }
    }
}
