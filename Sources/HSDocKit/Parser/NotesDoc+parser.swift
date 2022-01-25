import Parsing

extension NotesDoc {
    /// Parses a ``NotesDoc`` from a ``Substring``
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, NotesDoc> {
        Parse(NotesDoc.init(items:)) {
            blankDocLines
            DocLine("Notes:")
            List.parser()
        }
        .eraseToAnyParser()
    }
}
