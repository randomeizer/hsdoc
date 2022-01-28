import NonEmpty

/// Stores description text for an item.
public struct DescriptionDoc: Equatable {
    /// The lines of text in the description.
    public let lines: Lines
    
    public init(_ lines: Lines) {
        self.lines = lines
    }
    
    public init(_ head: String, _ tail: String...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.lines = lines
    }
}

extension DescriptionDoc {
    func text(for prefix: Doc.Prefix) -> String {
        "\(prefix) \(lines.joined(separator: "\n\(prefix) "))"
    }
}
