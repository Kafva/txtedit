import SwiftUI
import System

struct StartView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("latestAppFile") private var latestAppFile: URL?

    @State private var newFilename: String = ""
    @State private var fileImporterIsPresented = false
    @State private var newFileIsPresented = false

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            if let latestAppFile {
                if FileManager.default.access(latestAppFile) {
                    ButtonView(
                        action: { handleImport(url: latestAppFile) },
                        text: "Continue…  (\(latestAppFile.lastPathComponent))",
                        systemImage: "document.badge.clock"
                    )
                }
            }

            ButtonView(
                action: { fileImporterIsPresented = true },
                text: "Open…",
                systemImage: "document.badge.ellipsis"
            )
            .fileImporter(
                isPresented: $fileImporterIsPresented,
                allowedContentTypes: Const.allowedContentTypes,
                allowsMultipleSelection: false,
                onCompletion: { result in
                    switch result {
                    case .success(let urls):
                        guard let url = urls.first else {
                            return
                        }

                        if !url.startAccessingSecurityScopedResource() {
                            appState.currentError = "Could not gain access to: '\(url.path())'"
                            return
                        }

                        handleImport(url: url)

                        url.stopAccessingSecurityScopedResource()

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

        latestAppFile = newUrl
        appState.currentUrl = newUrl
        appState.editorContent = ""
        // Automatically enable editing for new files
        appState.editDisabled = false

        newFileIsPresented = false
    }

    private func handleImport(url: URL) {
        do {
            appState.editorContent = try String(contentsOf: url, encoding: .utf8)
            appState.currentUrl = url
            // Open existing files read-only
            appState.editDisabled = true

            // Do not update the `latestAppFile`, we get a security exception
            // if we try to access it again later, this API looks like what we
            // need, (macOS only)
            // https://developer.apple.com/documentation/foundation/nsurl/bookmarkcreationoptions/withsecurityscope
            LOG.debug(
                "Imported \(appState.editorContent.count) bytes from '\(url.path())'"
            )
        }
        catch {
            appState.currentError =
                "Error reading content: \(error.localizedDescription)"
        }
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
