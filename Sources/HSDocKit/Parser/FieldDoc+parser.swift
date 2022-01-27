import Parsing

extension FieldDoc {
    /// Parses a ``FieldDoc`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, FieldDoc> {
        Parse(FieldDoc.init) {
            DocLine(FieldSignature.parser())
            DocLine("Field")
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}
