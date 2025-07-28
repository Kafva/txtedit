import SwiftUI
import UIKit

struct EditorView: View {
    @EnvironmentObject var appState: AppState

    @State private var fileImporterIsPresented = false;
    @State private var newFileIsPresented = false;
    @State private var editDisabled = true;

    var body: some View {
        VStack(alignment: .center) {
            topBarView
            contentView.disabled(editDisabled)
        }
    }

    var topBarView: some View {
        HStack(spacing: 10) {
            Button(action: { appState.currentUrl = nil }) {
                Image(systemName: "chevron.left").foregroundColor(.accentColor)
            }

            if let currentUrl = appState.currentUrl {
                Text("\(currentUrl.lastPathComponent)")
                    .font(.title2)
                    .underline()
            }

            Spacer()

            Group {
                if editDisabled {
                    Button(action: { editDisabled = false }) {
                        Label("Edit", systemImage: "pencil.line")
                    }
                }
                else {
                    Button(action: handleSave) {
                        Text(":w").font(Const.saveButtonFont).foregroundColor(.green)
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
            try appState.editorContent.write(to: currentUrl, atomically: true, encoding: .utf8)
            editDisabled = true
        } catch {
            appState.currentError = "Error saving file: \(error.localizedDescription)"
        }
        currentUrl.stopAccessingSecurityScopedResource()
    }
}

// private struct BlockerView: View {
//     let active: Bool
//     var body: some View {
//         VStack {
//             if active {
//                 Spacer()
//                 Rectangle()
//                     .frame(width: Const.screenWidth, height: Const.screenHeight)
//                     .opacity(0.1)
//                     .onTapGesture {
//                         // There needs to be a onTapGesture registered for taps
//                         // to be properly blocked.
//                         Const.logger.debug("Tab selection tap gesture ignored")
//                     }
//             }
//         }
//     }
// }

