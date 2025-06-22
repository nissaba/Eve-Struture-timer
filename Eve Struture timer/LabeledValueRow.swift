//
//  LabeledValueRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//


import SwiftUI

/// A reusable horizontal row displaying a label and its corresponding value.
struct LabeledValueRow: View {
    /// The text label describing the value.
    let label: String
    /// The text value associated with the label.
    let value: String

    /// The view displaying the label and value side by side with specific font and layout.
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize() // ✅ Prend juste la place qu'il lui faut

            Text(value)
                .font(.body)
                .lineLimit(1)
                .fixedSize()
                // ✅ Évite le wrapping et l’étirement
        }
    }
}

