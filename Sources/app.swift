import SwiftUI

@main
struct TxtEditApp: App {
    @StateObject private var appState: AppState = AppState()

    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(appState)
        }
    }
}
