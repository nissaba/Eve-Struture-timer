//
//  LabeledValueRow.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-05-19.
//


import SwiftUI

struct LabeledValueRow: View {
    let label: String
    let value: String

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
