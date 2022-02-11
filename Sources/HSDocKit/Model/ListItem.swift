import NonEmpty

/// Represents a top-level bullet-pointed list item, for lists such as 'Parameters' and 'Returns'.
public struct ListItem: Equatable {
    /// The contents of the list item.
    public let lines: Lines
    
    public let items: List?
    
    /// Constructs a new `ListItem` with the specified lines.
    ///
    /// - Parameter lines: The lines of the list item.
    /// - Parameter items: Any sub-items of this item.
    public init(lines: Lines, items: List? = nil) {
        self.lines = lines
        self.items = items
    }
    
    /// Constructs a new `ListItem` with the specified lines.
    ///
    /// - Parameters:
    ///   - head: The first line.
    ///   - tail: Additional lines.
    public init(_ head: Substring, _ tail: Substring...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.lines = lines
        self.items = nil
    }
}

extension ListItem {
    func text(for prefix: Doc.Prefix) -> String {
        "\(lines.joined(separator: "\n\(prefix)    "))"
    }
}
