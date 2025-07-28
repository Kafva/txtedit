import SwiftUI
import UIKit

struct EditorView: View {
    @EnvironmentObject var appState: AppState

    @State private var fileImporterIsPresented = false;
    @State private var newFileIsPresented = false;

    var body: some View {
        VStack(alignment: .center) {
            topBarView
            contentView.disabled(appState.editDisabled)
        }
    }

    var topBarView: some View {
        HStack(spacing: 10) {
            Button(action: { appState.currentUrl = nil }) {
                Image(systemName: "chevron.left").foregroundColor(.accentColor)
            }

            if let currentUrl = appState.currentUrl {
                Text(currentUrl.lastPathComponent)
                    .font(.title2)
                    .underline()
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
                        Text(":w").font(Const.saveButtonFont)
                    }
                }
            }

        }
        .padding(.top, 20)
    }

    var contentView: some View {
        VStack(alignment: .center, spacing: 30) {
            TextEditor(text: $appState.editorContent)
                .multilineTextAlignment(.leading)
                .font(Const.editorFont)
                .autocorrectionDisabled()
                .autocapitalization(.none)
        }
        .padding([.leading, .trailing], 25)
    }

    private func handleSave() {
        guard let currentUrl = appState.currentUrl else {
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
        } catch {
            appState.currentError = "Error saving file: \(error.localizedDescription)"
        }
        currentUrl.stopAccessingSecurityScopedResource()
    }
}
