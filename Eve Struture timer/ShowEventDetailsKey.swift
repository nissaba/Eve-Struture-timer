//
//  ShowPreviewKey.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-10.
//
import SwiftUI

struct ShowSheetKey: FocusedValueKey {
    typealias Value = Binding<Bool>
}

extension FocusedValues {
    var showSheet: Binding<Bool>? {
        get { self[ShowSheetKey.self] }
        set { self[ShowSheetKey.self] = newValue }
    }
}
