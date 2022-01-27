import Parsing

extension MethodDoc {
    /// Parses a ``MethodDoc`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, MethodDoc> {
        Parse(MethodDoc.init) {
            DocLine(MethodSignature.parser())
            DocLine("Method")
            DescriptionDoc.parser()
            ParametersDoc.parser()
            ReturnsDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}
