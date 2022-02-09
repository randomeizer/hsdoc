import Parsing

extension ParagraphDoc {
    static let parser = OneOrMore {
        DocLine {
            optionalSpaces
            Prefix(1...)
        }
        .map { "\($0)\($1)" }
    } terminator: {
        blankDocLinesOrEnd
    }
    .map {
        ParagraphDoc(lines: $0)
    }
}
