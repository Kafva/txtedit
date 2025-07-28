import SwiftUI
import UIKit
import UniformTypeIdentifiers

enum Const {
    static let editorFont = Font.system(size: 17.0, design: .monospaced)
    static let saveButtonFont = Font.system(size: 20.0, design: .monospaced)

    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height

    static let allowedContentTypes: [UTType] = [
        .plainText,
        .text,
        .utf8PlainText,
        .tabSeparatedText,
        .commaSeparatedText,
        .log,
        .json,
        .yaml,
        .html,
        .css,
        .shellScript,
        .pythonScript,
    ]
}
