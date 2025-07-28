import SwiftUI

struct AppView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {

        VStack(alignment: .center, spacing: 30) {
            Text("Notepad")
                .font(.title)
                .padding(.top, 50)
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
