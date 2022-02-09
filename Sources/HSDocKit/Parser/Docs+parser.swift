import Parsing

/// A collection of ``Doc`` values.
typealias Docs = [DocBlock]

extension Docs {
    /// Parses a ``Docs`` value from a ``Substring``
    static let parser = Many {
        DocBlock.parser
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
        func parse(_ input: inout TextDocument) throws -> DocBlock {
            let original = input
            
            _ = NonDocLines().parse(&input)
            
            guard let firstLineNumber = input.first?.number else {
                input = original
                throw LintError.expected("a line of text")
            }
            
            let doc: Doc
            do {
                doc = try Doc.parser.parse(&input)
            } catch {
                input = original
                throw error
            }
            
            return .init(lineNumber: firstLineNumber, doc: doc)
        }
    }
}

extension DocBlock {
    static let parser = Parsers.DocBlockParser()
}
