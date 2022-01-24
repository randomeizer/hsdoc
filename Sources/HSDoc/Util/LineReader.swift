// Originally from: https://stackoverflow.com/a/40855152
import Foundation

/// Read text file line by line in efficient way. The ``Output`` is any type conforming to ``StringProtocol``.
public class LineReader<Output> where Output: StringProtocol {

    /// The file path.
    public let path: String
    
    /// The pointer to the open file.
    fileprivate let file: UnsafeMutablePointer<FILE>!
    
    /// Constructs a new ``LineReader`` pointing at a file at the specified `path`.
    /// If no file can be found or opened in `read` mode, `nil` is returned.
    ///
    /// - Parameter path: The path to the file.
    public init?(path: String) {
        self.path = path
        file = fopen(path, "r")
        guard file != nil else { return nil }
    }
    
    /// reads the next line from the file. Returns it as ``Output``, or `nil` if the file is empty.
    public var nextLine: Output? {
        var line: UnsafeMutablePointer<CChar>? = nil
        var linecap: Int = 0
        defer { free(line) }
        return getline(&line, &linecap, file) > 0 ? Output(cString: line!) : nil
    }

    deinit {
        fclose(file)
    }
}

extension LineReader: Sequence {
    /// Access the lines as an iterator.
    /// - Returns: The ``AnyIterator`` value.
    public func makeIterator() -> AnyIterator<Output> {
        return AnyIterator<Output> {
            return self.nextLine
        }
    }
}
