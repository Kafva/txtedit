import SwiftUI
import System

struct StartView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("latestFile") private var latestFile: URL?

    @State private var newFile: String = ""
    @State private var fileImporterIsPresented = false;
    @State private var newFileIsPresented = false;

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Button(action: { newFileIsPresented = true }) {
                Label("New…", systemImage: "document.badge.plus")
                    .font(.title2)
            }
            .alert("New filename", isPresented: $newFileIsPresented) {
                TextField(
                    newFile,
                    text: $newFile
                )
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .onSubmit {
                        handleSubmit()
                }
                Button("Continue") {
                        handleSubmit()
                }
                Button("Cancel", role: .cancel) {
                    newFileIsPresented = false
                }
            }

            Button(action: { fileImporterIsPresented = true }) {
                Label("Open…", systemImage: "document.viewfinder")
                    .font(.title2)
            }
            .fileImporter(
                isPresented: $fileImporterIsPresented,
                allowedContentTypes: [.plainText, .text],
                allowsMultipleSelection: false,
                onCompletion: handleImport,
            )
        }
        .padding([.leading, .trailing], 25)
    }

    private func handleSubmit() {
        let newUrl = FileManager.default.appDataDirectory.appending(path: newFile)
        appState.currentUrl = newUrl
        newFileIsPresented = false
    }

    private func handleImport(result: Result<[URL], any Error>) {
        switch result {
        case .success(let files):
            files.forEach { f in
                if !f.startAccessingSecurityScopedResource() {
                    appState.currentError = "Could not gain access to: '\(f.path())'"
                    return
                }

                do {
                    appState.editorContent = try String(contentsOf: f, encoding: .utf8)
                    appState.currentUrl = f
                }
                catch {
                    appState.currentError = 
                        "Error reading content: \(error.localizedDescription)"
                }
                f.stopAccessingSecurityScopedResource()
            }
        case .failure(let error):
            appState.currentError = error.localizedDescription
        }
    }
}
