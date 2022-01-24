import NonEmpty

/// Represents a top-level bullet-pointed list item, for lists such as 'Parameters' and 'Returns'.
public struct ListItem: Equatable {
    /// The contents of the list item.
    public let lines: Lines
    
    /// Constructs a new `ListItem` with the specified lines.
    ///
    /// - Parameter lines: The lines of the list item.
    public init(lines: Lines) {
        self.lines = lines
    }
    
    /// Constructs a new `ListItem` with the specified lines.
    ///
    /// - Parameters:
    ///   - head: The first line.
    ///   - tail: Additional lines.
    public init(_ head: String, _ tail: String...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.lines = lines
    }
}
