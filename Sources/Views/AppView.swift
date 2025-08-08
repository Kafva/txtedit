import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack {
            Spacer()

            if appState.currentError != nil {
                ErrorView().padding([.leading, .trailing], 25)
            }
            else if appState.currentUrl != nil {
                EditorView().padding([.leading, .trailing], 5)
            }
            else {
                StartView().padding([.leading, .trailing], 25)
            }

            Spacer()
        }
    }
}
