import SwiftUI
import AppKit

struct AboutThisAppView: View {
    var onClose: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 16) {
            Image("AppIconLarge")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(radius: 4)

            Text("Eve Online Structure Timer")
                .font(.title)
                .bold()

            Text(Bundle.appVersionAndBuild())
                .font(.subheadline)

            Text("A macOS app to track and manage Mercenary Den timers for Eve Online.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("© 2025 Pascale Beaulac")
                .font(.footnote)
                .foregroundColor(.secondary)

            HStack {
                Spacer()
                Button("Close") {
                    onClose?()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.top)
        }
        .padding()
        .fixedSize()
    }
}

#Preview {
    AboutThisAppView(onClose: {})
}
