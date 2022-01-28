import Parsing

extension DescriptionDoc {
    static func parser() -> AnyParser<TextDocument, DescriptionDoc> {
        OneOrMore {
            DocLine {
                optionalSpaces
                Prefix(1...)
            }
            .map { "\($0)\($1)" }
        }
        .map(DescriptionDoc.init)
        .eraseToAnyParser()
    }
}
