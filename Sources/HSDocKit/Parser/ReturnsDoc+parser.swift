import Parsing

extension ReturnsDoc {
    /// Parses a ``ReturnsDoc`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, ReturnsDoc> {
        Parse(ReturnsDoc.init(items:)) {
            blankDocLines
            DocLine("Returns:")
            List.parser()
        }
        .eraseToAnyParser()
    }
}
