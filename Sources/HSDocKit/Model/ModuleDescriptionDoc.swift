import NonEmpty

/// Contains the description text for a ``Doc.module``
public struct ModuleDescriptionDoc: Equatable {
    public typealias ParagraphDocs = NonEmpty<[ParagraphDoc]>
    
    public let paragraphs: ParagraphDocs
    
    public init(_ paragraphs: ParagraphDocs) {
        self.paragraphs = paragraphs
    }
}

extension ModuleDescriptionDoc {
    func text(for prefix: Doc.Prefix) -> String {
        paragraphs.map { $0.text(for: prefix) }.joined(separator: "\n\n")
    }
}

extension ModuleDescriptionDoc: CustomStringConvertible {
    public var description: String {
        text(for: .lua)
    }
}

extension ModuleDescriptionDoc {
    public init(_ head: Substring, _ tail: Substring...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.init(ParagraphDocs(.init(lines: lines)))
    }
}
