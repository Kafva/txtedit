import SwiftUI

struct ErrorView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(alignment: .leading) {
            Text("An error has occured")
                .bold()
                .font(.title2)
                .padding(.bottom, 10)
                .padding(.top, 10)
            Text(appState.currentError ?? "No description available")
                .font(.body)
                .foregroundColor(.red)

            HStack {
                Button(action: {
                    appState.currentError = nil
                    dismiss()
                }) {
                    Text("Dismiss").font(.body)
                }
                .buttonStyle(.bordered)
                Spacer()
            }
            .padding(.top, 30)
        }
    }
}
