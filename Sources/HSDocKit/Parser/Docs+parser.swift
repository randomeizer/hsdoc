import Parsing

/// Describes a parsed block of documentation mixed into other file content (eg. code).
public struct DocBlock: Equatable {
    /// The line number the block started on.
    public let lineNumber: UInt
    
    /// The documentation in the block.
    public let doc: Doc
}

extension DocBlock {
    public static let parser = Parsers.DocBlockParser()
}

extension DocBlock: CustomStringConvertible {
    public var description: String {
        """
        
        line \(lineNumber):
        \(doc)
        """
    }
}

extension Parsers {
    public struct DocBlockParser: Parser {
        public func parse(_ input: inout TextDocument) throws -> DocBlock {
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
