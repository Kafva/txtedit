import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            if appState.currentError != nil {
                ErrorView()
            }
            else if appState.currentUrl != nil {
                EditorView()
            }
            else {
                StartView()
            }
        }
        .padding([.leading, .trailing], 25)
    }
}
