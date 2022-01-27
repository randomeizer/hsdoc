import Parsing

extension DescriptionDoc {
    static func parser() -> AnyParser<TextDocument, DescriptionDoc> {
        Many(atLeast: 1) {
            DocLine {
                optionalSpaces
                Prefix(1...)
            }
            .map { "\($0)\($1)" }
        }
        .map { DescriptionDoc(.init($0)!) }
        .eraseToAnyParser()
    }
}
