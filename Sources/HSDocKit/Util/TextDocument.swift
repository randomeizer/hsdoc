import Parsing

/// A document consisting of multiple lines of text.
public typealias TextDocument = ArraySlice<TextLine>

//extension DocBlock {
//    func parser<Input>() -> Parsers.DocBlockParser<Input> where Input: StringProtocol {
//        .init()
//    }
//}
//
//extension Parsers {
//    struct DocBlockParser<Input>: Parser where Input: StringProtocol {
//
//        typealias Input = ArraySlice<Line<Input>>
//
//        @inlinable
//        func parse(_ input: inout ArraySlice<Line<Input>>) -> DocBlock? {
//            guard let firstLine = input.first else {
//                return nil
//            }
//
//            return DocBlock(lineNumber: firstLine.number, doc: doc)
//        }
//    }
//}

extension TextDocument {
    /// A parser which takes a ``Substring`` and outputs a ``TextDocument``.
    ///
    /// - Parameter firstLine: The for the first line in the text input. Defaults to `1`.
    /// - Returns: The ``Parser``
    public static func parser(firstLine: UInt = 1) -> Parser.TextDocumentParser {
        Parser.TextDocumentParser(firstLine: firstLine)
    }
}

extension Parsers {
    public struct TextDocumentParser: Parser {
        
        let firstLine: UInt
        
        init(firstLine: UInt = 1) {
            self.firstLine = firstLine
        }
        
        public func parse(_ input: inout Substring) -> TextDocument? {
            var result = TextDocument()
            
            var lineNumber = firstLine
            
            for line in input.split(separator: "\n", omittingEmptySubsequences: false) {
                result.append(.init(lineNumber, text: line))
                lineNumber = lineNumber + 1
            }
            
            input = ""[...]
            return result
        }
    }
}

extension Parser {
    public typealias TextDocumentParser = Parsers.TextDocumentParser
}

extension TextDocument {
    public init(firstLine: UInt = 1, content: Substring) {
        let parser = Self.parser(firstLine: firstLine)
        var input = content
        self = parser.parse(&input)!
    }
    
    public init(firstLine: UInt = 1, content: String) {
        self.init(firstLine: firstLine, content: content[...])
    }
    
    public init(firstLine: UInt = 1, content: () -> Substring) {
        self.init(firstLine: firstLine, content: content())
    }
    
    public init(firstLine: UInt = 1, content: () -> String) {
        self.init(firstLine: firstLine, content: content())
    }
}
