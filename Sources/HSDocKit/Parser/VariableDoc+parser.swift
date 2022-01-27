import Parsing

extension VariableDoc {
    /// Parses a ``VariableDoc`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, VariableDoc> {
        Parse(VariableDoc.init) {
            DocLine(VariableSignature.parser())
            DocLine("Variable")
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}
