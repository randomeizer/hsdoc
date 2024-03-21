import Parsing

extension NotesDoc {
    /// Parses a ``NotesDoc`` from a ``Substring``
    static let parser = Parse(NotesDoc.init(items:)) {
        Try {
            blankDocLine
        } catch: { error in
            throw LintError.expected("blank line before Notes")
        }
        DocLine("Notes:")
        BulletList.parser
    }
}
