import SwiftUI

class AppState: ObservableObject {
    @Published var currentUrl: URL?
    @Published var currentError: String?
    @Published var editorContent: String = ""
    @Published var editDisabled = true
}

