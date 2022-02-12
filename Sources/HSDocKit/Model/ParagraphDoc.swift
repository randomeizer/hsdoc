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
    public init(_ head: Substring, _ tail: Substring...) {
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

extension ParagraphDoc: CustomStringConvertible {
    public var description: String {
        text(for: .lua)
    }
}

extension ParagraphDoc: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        if let lines = NonEmpty<[Substring]>(stringLiteral.split(separator: "\n")) {
            self.init(lines: lines)
        } else {
            self.init(stringLiteral[...])
        }
    }
}
