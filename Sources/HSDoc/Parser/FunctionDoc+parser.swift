 import Parsing

extension FunctionDoc {
    /// Parses a ``FunctionDoc`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, FunctionDoc> {
        Parse(FunctionDoc.init) {
            DocLine(FunctionSignature.parser())
            DocLine("Function")
            DescriptionDoc.parser()
            ParametersDoc.parser()
            ReturnsDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}
