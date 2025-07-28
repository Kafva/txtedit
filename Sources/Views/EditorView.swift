import SwiftUI
import UIKit

struct EditorView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(alignment: .center) {
            topHeader.padding(.top, 20)
            TextEditor(text: $appState.editorContent)
                .multilineTextAlignment(.leading)
                .font(Const.editorFont)
                .autocorrectionDisabled()
                .autocapitalization(.none)
                .padding([.leading, .trailing], 25)
                .disabled(appState.editDisabled)
        }
    }

    private var topHeader: some View {
        HStack(spacing: 10) {
            Button(action: { appState.currentUrl = nil }) {
                Image(systemName: "chevron.left")
                    .bold()
                    .font(Const.saveButtonFont)
                    .foregroundColor(.accentColor)
            }

            if let currentUrl = appState.currentUrl {
                Text(currentUrl.lastPathComponent)
                    .underline()
                    .padding([.leading, .trailing], 8)
                    .lineLimit(1)
                    .font(.title)
            }

            Spacer()

            Group {
                if appState.editDisabled {
                    Button(action: { appState.editDisabled = false }) {
                        Label("Edit", systemImage: "pencil.line").bold()
                    }
                }
                else {
                    Button(action: handleSave) {
                        Text(":w").font(Const.saveButtonFont).bold()
                    }
                }
            }
        }
    }

    private func handleSave() {
        guard let currentUrl = appState.currentUrl else {
            appState.currentError = "No current URL to save"
            return
        }
        do {
            if !currentUrl.startAccessingSecurityScopedResource() {
                appState.currentError = "Could not gain access to: '\(currentUrl.path())'"
                return
            }
            try appState.editorContent.write(
                to: currentUrl,
                atomically: true,
                encoding: .utf8
            )
            appState.editDisabled = true
            LOG.debug("Wrote \(appState.editorContent.count) bytes to '\(currentUrl.path())'")
        } catch {
            appState.currentError = "Error saving file: \(error.localizedDescription)"
        }
        currentUrl.stopAccessingSecurityScopedResource()
    }
}
