import NonEmpty

/// Contains the description text for a ``Doc.module``
public struct ModuleDetailsDoc: Equatable {
    public typealias ParagraphDocs = NonEmpty<[ParagraphDoc]>
    
    public let paragraphs: ParagraphDocs
    
    public init(_ paragraphs: ParagraphDocs) {
        self.paragraphs = paragraphs
    }
}

extension ModuleDetailsDoc {
    func text(for prefix: Doc.Prefix) -> String {
        paragraphs.map { $0.text(for: prefix) }.joined(separator: "\n---\n")
    }
}

extension ModuleDetailsDoc: CustomStringConvertible {
    public var description: String {
        text(for: .lua)
    }
}

extension ModuleDetailsDoc {
    public init(_ head: ParagraphDoc, _ tail: ParagraphDoc...) {
        var paragraphs = ParagraphDocs(head)
        paragraphs.append(contentsOf: tail)
        self.init(paragraphs)
    }
}
