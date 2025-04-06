//
//  ValidationTextField.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-11.
//

import SwiftUI
import Combine

// MARK: - Validator Protocol

/// A protocol for validating input strings.
protocol Validator {
    /// Determines if the provided input is valid.
    func isValid(_ input: String) -> Bool
}

// MARK: - RegexValidator

/// A concrete implementation of `Validator` using regular expressions.
struct RegexValidator: Validator {
    /// The regular expression pattern used for validation.
    private let pattern: String

    /// Initializes the validator with a regex pattern.
    /// - Parameter pattern: A regular expression pattern string.
    init(pattern: String) {
        self.pattern = pattern
    }

    /// Validates the input string against the regex pattern.
    /// - Parameter input: The string to validate.
    /// - Returns: A Boolean indicating whether the input is valid.
    func isValid(_ input: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex.firstMatch(in: input, options: [], range: range) != nil
    }
}

// MARK: - ValidationTextField

/// A reusable text field view with real-time validation and visual feedback.
struct ValidationTextField: View {
    @Binding var text: String
    @Binding var isValid: Bool
    let placeHolder: String
    let errorMessage: String
    let label: String?

    /// Validator used to check the text field's content.
    private let validator: Validator

    /// Tracks how many times validation has failed (used for shaking animation).
    @State private var attempts = 0

    /// Manages the focus state of the text field.
    @FocusState private var isTextFieldFocused: Bool

    /// Initializes a validation text field.
    /// - Parameters:
    ///   - text: A binding to the text input.
    ///   - label: Optional label to display above the text field.
    ///   - isValid: A binding to the validation result.
    ///   - placeHolder: Placeholder text.
    ///   - errorMessage: Error message to display when validation fails.
    ///   - validator: A conforming `Validator` instance to validate input.
    init(
        text: Binding<String>,
        label: String? = nil,
        isValid: Binding<Bool>,
        placeHolder: String,
        errorMessage: String,
        validator: Validator
    ) {
        self._text = text
        self.label = label
        self._isValid = isValid
        self.placeHolder = placeHolder
        self.errorMessage = errorMessage
        self.validator = validator
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Optional label above the field
            if let label, !label.isEmpty {
                Text(label)
                    .font(.headline)
            }

            // Main text field with border and shake animation
            TextField(placeHolder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 2)
                )
                .modifier(Shake(animatableData: CGFloat(attempts)))
                .focused($isTextFieldFocused)
                .onAppear {
                    validate(animate: false)
                }
                .onChange(of: text) { _, _ in
                    validate(animate: false)
                }
                .onChange(of: isTextFieldFocused) { _, newValue in
                    if !newValue {
                        validate()
                    }
                }
                .onSubmit {
                    validate()
                }

            // Error message shown when input is invalid
            Text(!isValid ? errorMessage : "")
                .font(.caption)
                .foregroundColor(.red)
                .padding(.leading, 5)
        }
        .padding(.horizontal)
    }

    /// Performs validation using the provided validator.
    /// Optionally triggers a shake animation on failure.
    /// - Parameter animate: Whether to animate the shake on failure.
    private func validate(animate: Bool = true) {
        let newValidity = validator.isValid(text)
        if !newValidity && animate {
            withAnimation(.default) {
                attempts += 1
            }
        }
        isValid = newValidity
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

#Preview {
    
    let validator = RegexValidator(pattern: #"^(\d{1,2}):([0-1]?\d|2[0-3]):([0-5]?\d)?$"#)

        ValidationTextField(
            text: .constant("TEXT"),
            label: "Time",
            isValid: .constant(false),
            placeHolder: "Enter time (DD:HH:MM)",
            errorMessage: "Invalid format. Expected DD:HH:MM",
            validator: validator
        )
    }

