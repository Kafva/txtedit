import SwiftUI
import UIKit

struct EditorView: View {
    @EnvironmentObject var appState: AppState

    @State private var alertIsPresented = false

    var body: some View {
        VStack(alignment: .leading) {
            topHeader.padding([.top, .bottom], 20)
            Group {
                if appState.editDisabled {
                    ScrollView {
                        Text(appState.editorContent)
                    }
                }
                else {
                    TextEditor(text: $appState.editorContent)
                }
            }
            .multilineTextAlignment(.leading)
            .font(Const.editorFont)
            .autocorrectionDisabled()
            .autocapitalization(.none)
            .padding([.leading, .trailing], 5)
        }
    }

    private var topHeader: some View {
        HStack(spacing: 10) {
            Button(action: {
                if appState.savedEditorContent == appState.editorContent {
                    handleBack()
                }
                else {
                    alertIsPresented = true
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(Const.editorButtonFont)
                    .foregroundColor(.accentColor)
            }
            .alert("Discard unsaved changes?", isPresented: $alertIsPresented) {
                Button("Yes", role: .destructive) {
                    handleBack()
                }
            }

            if let currentUrl = appState.currentUrl {
                Text(currentUrl.lastPathComponent)
                    .padding([.leading, .trailing], 8)
                    .lineLimit(1)
                    .font(Const.editorTitleFont)
            }

            Spacer()

            Group {
                if appState.editDisabled {
                    Button(action: { appState.editDisabled = false }) {
                        Image(systemName: "pencil.line")
                    }
                }
                else if appState.savedEditorContent != appState.editorContent {
                    Button(action: handleSave) {
                        Text(":w")
                    }
                }
            }
            .font(Const.editorButtonFont)
        }
        .padding([.leading, .trailing], 10)
    }

    private func handleBack() {
        appState.currentUrl = nil
        appState.savedEditorContent = ""
        appState.editorContent = ""
    }

    private func handleSave() {
        guard let currentUrl = appState.currentUrl else {
            appState.currentError = "No current URL to save"
            return
        }
        do {
            _ = currentUrl.startAccessingSecurityScopedResource()
            try appState.editorContent.write(
                to: currentUrl,
                atomically: true,
                encoding: .utf8
            )
            appState.savedEditorContent = appState.editorContent
            appState.editDisabled = true
            LOG.debug(
                "Wrote \(appState.editorContent.count) bytes to '\(currentUrl.path())'"
            )
        }
        catch {
            appState.currentError =
                "Error saving file: \(error.localizedDescription)"
        }
        currentUrl.stopAccessingSecurityScopedResource()
    }
}
