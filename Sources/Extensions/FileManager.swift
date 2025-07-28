import Foundation

extension FileManager {
    var appDataDirectory: URL {
        self.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
