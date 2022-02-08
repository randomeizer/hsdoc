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
        func parse(_ input: inout TextDocument) throws -> DocBlock {
            let original = input
            
            let _ = try NonDocLines().parse(&input)
            
            guard let firstLineNumber = input.first?.number else {
                input = original
                throw ParsingError.expectedInput("a line of text", at: input)
            }
            
            let doc: Doc
            do {
                doc = try Doc.parser().parse(&input)
            } catch {
                input = original
                throw error
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
