import Parsing

/// A collection of ``Doc`` values.
typealias Docs = [DocBlock]

extension Docs {
    /// Parses a ``Docs`` value from a ``Substring``
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, Docs> {
        Many {
            DocBlock.parser()
        }
        .eraseToAnyParser()
    }
}

/// Describes a parsed block of documentation mixed into other file content (eg. code).
struct DocBlock: Equatable {
    /// The line number the block started on.
    let lineNumber: UInt
    
    /// The documentation in the block.
    let doc: Doc
}

extension Parsers {
    struct DocBlockParser: Parser {
        func parse(_ input: inout TextDocument) -> DocBlock? {
            let original = input
            guard NonDocLines().parse(&input) != nil else {
                return nil
            }
            
            guard let firstLineNumber = input.first?.number else {
                input = original
                return nil
            }
            
            guard let doc = Doc.parser().parse(&input) else {
                input = original
                return nil
            }
            
            return .init(lineNumber: firstLineNumber, doc: doc)
        }
    }
}

extension DocBlock {
    static func parser() -> Parsers.DocBlockParser {
        Parsers.DocBlockParser()
    }
}
