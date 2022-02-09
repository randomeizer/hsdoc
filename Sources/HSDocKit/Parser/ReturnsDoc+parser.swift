import Parsing

extension ReturnsDoc {
    /// Parses a ``ReturnsDoc`` from a ``Substring``.
    static let parser = Parse(ReturnsDoc.init(items:)) {
        DocLine("Returns:")
        List.parser
    }
}
