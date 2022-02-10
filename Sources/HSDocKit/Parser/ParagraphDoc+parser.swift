import Parsing

extension ParagraphDoc {
    static let parser = OneOrMore {
        nonBlankDocLine
    } terminator: {
        blankDocLinesOrEnd
    }
    .map { lines in
        ParagraphDoc(lines: lines)
    }
}
