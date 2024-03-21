import NonEmpty

/// Stores description text for an item.
public struct DescriptionDoc: Equatable {
    /// A single paragraph of text.
    public let paragraph: ParagraphDoc
    
    public init(_ paragraph: ParagraphDoc) {
        self.paragraph = paragraph
    }
}

extension DescriptionDoc {
    func text(for prefix: Doc.Prefix) -> String {
        paragraph.text(for: prefix)
    }
}

extension DescriptionDoc {
    public init(_ head: Substring, _ tail: Substring...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.init(ParagraphDoc(lines: lines))
    }
}
