import SwiftUI

struct AboutThisAppView: View {
    var onClose: (() -> Void)? = nil
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)
            Text("Eve Online Mercenary Den Timers")
                .font(.title)
                .bold()
            Text("Version 1.0.0")
                .font(.subheadline)
            Text("A macOS app to track and manage Mercenary Den timers for Eve Online.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text("© 2025 Pascale Beaulac")
                .font(.footnote)
                .foregroundColor(.secondary)
            Button("Close") {
                onClose?()
            }
            .padding(.top, 20)
        }
        .padding(40)
        .frame(minWidth: 350, minHeight: 320)
    }
}

#Preview {
    AboutThisAppView(onClose: {})
}
