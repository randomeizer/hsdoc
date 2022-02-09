import NonEmpty

/// Describes a paragraph of text, ended by either a blank ``DocLine`` no further ``DocLine``s.
public struct ParagraphDoc: Equatable {
    let lines: Lines
    
    public init(lines: Lines) {
        self.lines = lines
    }
    
    /// Constructs a new `ParagraphDoc` with the specified lines.
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

extension ParagraphDoc {
    func text(for prefix: Doc.Prefix) -> String {
        "\(prefix) \(lines.joined(separator: "\n\(prefix) "))"
    }
}
