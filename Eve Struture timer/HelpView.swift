import SwiftUI

struct HelpView: View {
    let closeAction: () -> Void

    private let appWebsiteURL = URL(string: "https://nissabba.github.io")!
    private let supportEmailURL = URL(string: "mailto:nissaa@gmail.com?subject=Eve%20Structure%20Timer%20Support")!

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Need Help?")
                .font(.title2.bold())

            Text("If you have questions or encounter a problem, you can:")
                .font(.body)

            VStack(alignment: .leading, spacing: 8) {
                Link("Visit the Eve Structure Timer website", destination: appWebsiteURL)
                Link("Contact support via email", destination: supportEmailURL)
            }

            HStack {
                Spacer()
                Button("Close", action: closeAction)
                    .keyboardShortcut(.cancelAction)
            }
        }
        .padding()
        .fixedSize() // 👈 rend la vue compacte
    }
}
