import SwiftUI
import UIKit

struct EditorView: View {
    @EnvironmentObject var appState: AppState

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
            Button(action: { appState.currentUrl = nil }) {
                Image(systemName: "chevron.left")
                    .font(Const.editorButtonFont)
                    .foregroundColor(.accentColor)
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
                        Label("Edit", systemImage: "pencil.line")
                    }
                }
                else {
                    Button(action: handleSave) {
                        Text(":w")
                    }
                }
            }
            .font(Const.editorButtonFont)
        }
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
