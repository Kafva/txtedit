import SwiftUI
import UIKit
import UniformTypeIdentifiers

enum Const {
    static let editorFont = Font.system(size: 18.0, design: .monospaced)
    static let editorButtonFont = Font.system(size: 20.0, design: .serif)
        .italic().bold()
    static let editorTitleFont = Font.system(size: 22.0, design: .serif)
        .italic().bold()

    static let allowedContentTypes: [UTType] = [
        .plainText,
        .text,
        .utf8PlainText,
        .tabSeparatedText,
        .commaSeparatedText,
        .log,
        .json,
        .yaml,
        .playlist,
    ]
}
