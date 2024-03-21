import Parsing

extension ParagraphDoc {
    /// Parses non-blank documentation lines, stopping before the first
    /// blank doc line, non-doc line, or the end of input.
    static let parser = OneOrMore {
        nonBlankDocLine
    } terminator: {
        blankDocLineOrEnd
    }
    .map { lines in
        ParagraphDoc(lines: lines)
    }
}
