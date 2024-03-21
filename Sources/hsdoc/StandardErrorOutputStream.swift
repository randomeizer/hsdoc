import Foundation

// Usage: print("foo", to: &stdErr)
struct StandardErrorOutputStream: TextOutputStream {
    func write(_ string: String) {
        FileHandle.standardError.write(Data(string.utf8))
    }
}
