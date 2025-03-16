//
//  ValidationTextField.swift
//  Eve Struture timer
//
//  Created by Pascale on 2025-03-11.
//

import SwiftUI
import Combine

// MARK: - Validator Protocol
protocol Validator {
    func isValid(_ input: String) -> Bool
}

// MARK: - RegexValidator
struct RegexValidator: Validator {
    private let pattern: String

    init(pattern: String) {
        self.pattern = pattern
    }

    func isValid(_ input: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return false
        }
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex.firstMatch(in: input, options: [], range: range) != nil
    }
}

// MARK: - ValidationTextField
struct ValidationTextField: View {
    @Binding var text: String
    @Binding var isValid: Bool
    let placeHolder: String
    let errorMessage: String
    private let validator: Validator
    @State private var attempts = 0
    @FocusState private var isTextFieldFocused: Bool

    init(text: Binding<String>, isValid: Binding<Bool>, placeHolder: String, errorMessage: String, validator: Validator) {
        self._text = text
        self._isValid = isValid
        self.placeHolder = placeHolder
        self.errorMessage = errorMessage
        self.validator = validator
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(placeHolder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isValid ? Color.clear : Color.red, lineWidth: 2)
                )
                .modifier(Shake(animatableData: CGFloat(attempts)))
                .focused($isTextFieldFocused)
                .onChange(of: text) { _,_ in
                    validate(animate: false)
                }
                .onChange(of: isTextFieldFocused) { oldValue, newValue in
                    if !newValue {
                        validate()
                    }
                }
                .onSubmit { validate() }
            
            Text(!isValid ? errorMessage : "")
                .font(.caption)
                .foregroundColor(.red)
                .padding(.leading, 5)
        }
        .padding(.horizontal)
    }
    
    private func validate(animate: Bool = true) {
        let newValidity = validator.isValid(text)
        if !newValidity && animate {
            withAnimation(.default) { attempts += 1 }
        }
        isValid = newValidity
    }
}

// MARK: - Shake Effect
struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

#Preview {
    
    let validator = RegexValidator(pattern: #"^(\d{1,2}):([0-1]?\d|2[0-3]):([0-5]?\d)?$"#)

        ValidationTextField(
            text: .constant("TEXT"),
            isValid: .constant(false),
            placeHolder: "Enter time (DD:HH:MM)",
            errorMessage: "Invalid format. Expected DD:HH:MM",
            validator: validator
        )
    }

