import Parsing

extension NotesDoc {
    /// Parses a ``NotesDoc`` from a ``Substring``
    static let parser = Parse(NotesDoc.init(items:)) {
        DocLine("Notes:")
        List.parser
    }
}
