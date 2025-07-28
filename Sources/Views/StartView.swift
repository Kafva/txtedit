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
            if let latestFile {
                Button(action: { appState.currentUrl = latestFile }) {
                    Label("Continue…", systemImage: "document.badge.clock.fill")
                        .font(.title2)
                }
            }
            Button(action: {
                newFileIsPresented = true
            }) {
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
                        handleNewFileSubmit()
                }
                Button("Continue") {
                        handleNewFileSubmit()
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

    private func handleNewFileSubmit() {
        let newUrl = FileManager.default.appDataDirectory.appending(path: newFile)
        latestFile = newUrl
        appState.currentUrl = newUrl
        newFileIsPresented = false
        appState.editDisabled = false
    }

    private func handleImport(result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            urls.forEach { url in
                if !url.startAccessingSecurityScopedResource() {
                    appState.currentError = "Could not gain access to: '\(url.path())'"
                    return
                }

                do {
                    appState.editorContent = try String(contentsOf: url, encoding: .utf8)
                    latestFile = url
                    appState.currentUrl = url
                }
                catch {
                    appState.currentError =
                        "Error reading content: \(error.localizedDescription)"
                }
                url.stopAccessingSecurityScopedResource()
            }
        case .failure(let error):
            appState.currentError = error.localizedDescription
        }
    }
}
