import Foundation

extension FileManager {
    var appDataDirectory: URL {
        self.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func access(_ at: URL) -> Bool {
        var unused: ObjCBool = true
        let atPath = at.path(percentEncoded: false)
        let exists = FileManager.default.fileExists(
            atPath: atPath,
            isDirectory: &unused)
        return exists
    }
}
