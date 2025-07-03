import SwiftUI

struct CustomNumberPicker: View {
    @Binding var value: Int
    var maxValue: Int
    var width: CGFloat = 30
    @State private var input: String = ""

    var body: some View {
        HStack(spacing: 2) {
            TextField("", text: $input)
                .frame(width: width)
                .multilineTextAlignment(.center)
                .onChange(of: input) { oldValue, newValue in
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        input = filtered
                    }
                    if let intValue = Int(filtered), intValue <= maxValue {
                        value = intValue
                    } else if filtered.isEmpty {
                        value = 0
                    } else if let intValue = Int(filtered), intValue > maxValue {
                        input = oldValue
                    }
                }
                .onChange(of: value) { _, newValue in
                    input = String(newValue)
                }
                .onAppear {
                    input = String(value)
                }
            VStack(spacing: 0) {
                Button(action: {
                    value = min(value + 1, maxValue)
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 10, weight: .bold))
                }.buttonStyle(BorderlessButtonStyle())
                Button(action: {
                    value = max(value - 1, 0)
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .bold))
                }.buttonStyle(BorderlessButtonStyle())
            }
        }
    }
}

struct CustomNumberPickerWrapper: View {
    @State private var value = 0
    var body: some View {
        VStack(spacing: 20) {
            CustomNumberPicker(value: $value, maxValue: 23)
            Text("Current value: \(value)")
        }
        .padding()
    }
}

#Preview {
    CustomNumberPickerWrapper()
}
