import Parsing

extension ModuleDescriptionDoc {
    static let parser = OneOrMore {
        blankDocLine
        ParagraphDoc.parser
    }
    .map(Self.init)
}
