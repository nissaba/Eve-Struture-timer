//
//  ValidationTextField.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-11.
//

import SwiftUI
import Combine

// MARK: - ValidationTextField

/// A reusable text field with auto-focus on error.
///
/// This component observes an optional error message. When the error transitions from
/// `nil` to a non-`nil` value, the field will:
///  - Automatically become focused
///  - Trigger a shake animation
///
/// The parent view is expected to handle validation logic externally, setting the
/// `errorMessage` appropriately based on user input.
struct ValidationTextField: View {

    // MARK: - Inputs

    /// The text content bound to the field.
    @Binding var text: String

    /// The optional error message to display. A `nil` value indicates valid input.
    @Binding var errorMessage: String?

    /// Placeholder text shown when the field is empty.
    let placeHolder: String

    /// Optional label displayed above the text field.
    let label: String?

    /// Callback triggered when the field loses focus or the user presses return.
    let onValidate: (() -> Void)?

    // MARK: - Focus & Animation

    /// Local focus state for the embedded `TextField`.
    @FocusState private var isFocused: Bool

    /// Trigger counter for shake animation.
    @State private var shakeTrigger: Int = 0

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Optional field label
            if let label, !label.isEmpty {
                Text(label)
                    .font(.headline)
            }

            // The main input field
            TextField(placeHolder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(errorMessage == nil ? Color.clear : Color.red, lineWidth: 2)
                )
                .modifier(Shake(animatableData: CGFloat(shakeTrigger)))
                .focused($isFocused)
                .onSubmit {
                    onValidate?()
                }
                .onChange(of: isFocused) { _, newValue in
                    if !newValue {
                        onValidate?()
                    }
                }
                .onChange(of: errorMessage) { old, new in
                    if old == nil && new != nil {
                        isFocused = true
                        withAnimation(.default) {
                            shakeTrigger += 1
                        }
                    }
                }

            // Error message display
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.leading, 5)
            }
        }
        .padding(.horizontal)
    }
}
// MARK: - Shake Effect

/// A view modifier that applies a shake animation when the validation fails.
struct Shake: GeometryEffect {
    var amount: CGFloat = 10        // Horizontal shake amount
    var shakesPerUnit = 3           // Number of shakes per animation unit
    var animatableData: CGFloat     // Driven by attempt count

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0
            )
        )
    }
}


#Preview("Valid") {
    @Previewable @State var text: String = "8"
    @Previewable @State var error: String? = nil

    ValidationTextField(
        text: $text,
        errorMessage: $error,
        placeHolder: "Enter a number",
        label: "Planet Number"
    ){}
    .padding()
}

#Preview("Empty Input") {
    @Previewable @State var text: String = ""
    @Previewable @State var error: String? = "Field is required"

    ValidationTextField(
        text: $text,
        errorMessage: $error,
        placeHolder: "e.g. Jita",
        label: "System Name"
    ){}
    .padding()
}
