import Parsing

extension NotesDoc {
    /// Parses a ``NotesDoc`` from a ``Substring``
    static let parser = Parse(NotesDoc.init(items:)) {
        Require {
            blankDocLine
        } orThrow: {
            LintError.expected("blank line before Notes")
        }
        DocLine("Notes:")
        List.parser
    }
}
