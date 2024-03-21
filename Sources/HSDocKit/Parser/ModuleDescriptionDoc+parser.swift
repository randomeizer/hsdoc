import Parsing

extension ModuleDetailsDoc {
    static let parser = OneOrMore {
        blankDocLine
        ParagraphDoc.parser
    }
    .map(Self.init)
    .eraseToAnyParser()
}
