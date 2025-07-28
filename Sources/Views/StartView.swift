import SwiftUI
import System

struct StartView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("latestFile") private var latestFile: URL?

    @State private var newFilename: String = ""
    @State private var fileImporterIsPresented = false
    @State private var newFileIsPresented = false

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            if let latestFile {
                ButtonView(
                    action: { handleImport(url: latestFile) },
                    text: "Continue…  (\(latestFile.lastPathComponent))",
                    systemImage: "document.badge.clock"
                )
            }

            ButtonView(
                action: { fileImporterIsPresented = true },
                text: "Open…",
                systemImage: "document.badge.ellipsis"
            )
            .fileImporter(
                isPresented: $fileImporterIsPresented,
                allowedContentTypes: [.plainText, .text],
                allowsMultipleSelection: false,
                onCompletion: { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else {
                            return
                        }
                        handleImport(url: url)
                    case .failure(let error):
                        appState.currentError = error.localizedDescription
                    }
                },
            )

            ButtonView(
                action: { newFileIsPresented = true },
                text: "New…",
                systemImage: "document.badge.plus"
            )
            .alert("New filename", isPresented: $newFileIsPresented) {
                TextField(newFilename, text: $newFilename)
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
        }
        .lineLimit(1)
        .padding([.leading, .trailing], 25)
    }

    private func handleNewFileSubmit() {
        let newUrl = FileManager.default.appDataDirectory.appending(
            path: newFilename)

        if FileManager.default.access(newUrl) {
            appState.currentError = "Path already exists: '\(newUrl.path())'"
            return
        }

        latestFile = newUrl
        appState.currentUrl = newUrl
        appState.editorContent = ""
        // Automatically enable editing for new files
        appState.editDisabled = false

        newFileIsPresented = false
    }

    private func handleImport(url: URL) {
        if !url.startAccessingSecurityScopedResource() {
            appState.currentError = "Could not gain access to: '\(url.path())'"
            return
        }

        do {
            appState.editorContent = try String(
                contentsOf: url, encoding: .utf8)
            appState.currentUrl = url
            latestFile = url
            LOG.debug(
                "Imported \(appState.editorContent.count) bytes from '\(url.path())'"
            )
        }
        catch {
            appState.currentError =
                "Error reading content: \(error.localizedDescription)"
        }
        url.stopAccessingSecurityScopedResource()
    }
}

private struct ButtonView: View {
    var action: () -> Void
    var text: String
    var systemImage: String

    var body: some View {
        Button(action: action) {
            Label(text, systemImage: systemImage)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
