import Parsing

extension DescriptionDoc {
    static let parser = ParagraphDoc.parser
        .map(DescriptionDoc.init)
}
