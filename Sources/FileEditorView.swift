import SwiftUI
import UniformTypeIdentifiers

struct FileEditorView: View {
    @State private var textContent: String = ""
    @State private var isImporting: Bool = false
    @State private var isSaving: Bool = false
    @State private var selectedFileUrl: URL? = nil
    @State private var saveStatusMessage: String = ""
    @State private var saveStatusColor: Color = .gray
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            TextEditor(text: $textContent)
                .border(Color.gray, width: 1)
                .padding()

            HStack {
                Button("Open File") {
                    isImporting = true
                }
                .buttonStyle(.borderedProminent)
                .fileImporter(
                    isPresented: $isImporting,
                    allowedContentTypes: [.plainText, .text],
                    allowsMultipleSelection: false
                ) { result in
                    switch result {
                    case .success(let files):
                        files.forEach { file in
                            // gain access to the directory
                            let gotAccess = file.startAccessingSecurityScopedResource()
                            if !gotAccess { return }

                            do {
                                // access the directory URL
                                // (read templates in the directory, make a bookmark, etc.)
                                textContent = try String(contentsOf: file, encoding: .utf8)
                            }
                            catch {
                                print("\(error.localizedDescription)")
                            }

                            // release access
                            file.stopAccessingSecurityScopedResource()
                        }
                    case .failure(let error):
                        print(error)
                    }
                }

                Button("Save File") {
                    isSaving = true
                    saveFile()
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedFileUrl == nil)
            }
            .padding()

            Text(saveStatusMessage)
                .foregroundColor(saveStatusColor)
                .padding(.bottom)

            Spacer()

        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func saveFile() {
        guard let fileURL = selectedFileUrl else {
            alertTitle = "No File Selected"
            alertMessage = "Please open a file before saving."
            showAlert = true
            return
        }

        do {
            try textContent.write(to: fileURL, atomically: true, encoding: .utf8)
            saveStatusMessage = "File saved successfully!"
            saveStatusColor = .green
        } catch {
            saveStatusMessage = "Error saving file: \(error.localizedDescription)"
            saveStatusColor = .red
            alertTitle = "Error Saving File"
            alertMessage = "Could not save the file: \(error.localizedDescription)"
            showAlert = true
            print("Error saving file: \(error)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            saveStatusMessage = ""
            saveStatusColor = .gray
        }
    }
}

struct FileEditorView_Previews: PreviewProvider {
    static var previews: some View {
        FileEditorView()
    }
}

