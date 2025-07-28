import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Spacer()

            if appState.currentError != nil {
                ErrorView()
            }
            else if appState.currentUrl != nil {
                EditorView()
            }
            else {
                StartView()
            }

            Spacer()
        }
        .padding([.leading, .trailing], 25)
    }
}
