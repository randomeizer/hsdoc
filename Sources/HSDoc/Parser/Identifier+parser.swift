import Parsing

extension Identifier {
    /// Parses a `Substring` to an `Identifier`
    /// - Returns: the parser
    static func parser() -> AnyParser<Substring, Identifier> {
        Parse(Identifier.init(_:)) {
            Require(Prefix(1) { $0.isLetter || $0 == "_" })
            Prefix(while: isIdentifier(_:)).map(String.init)
        }
        .eraseToAnyParser()
    }
}
