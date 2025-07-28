import SwiftUI

@main
struct TodoMdApp: App {
    @StateObject private var appState: AppState = AppState()

    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(appState)
        }
    }
}
