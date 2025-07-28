import Foundation

extension FileManager {
    var localDocumentsDirectory: URL {
        self.urls(for: .documentDirectory, in: .localDomainMask)[0]
    }

    var appDataDirectory: URL {
        self.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
