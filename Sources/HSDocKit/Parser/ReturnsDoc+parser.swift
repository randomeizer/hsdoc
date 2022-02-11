import Parsing

extension ReturnsDoc {
    /// Parses a ``ReturnsDoc`` from a ``Substring``.
    static let parser = Parse(ReturnsDoc.init(items:)) {
        Require {
            blankDocLine
        } orThrow: {
            LintError.expected("blank line before Returns")
        }
        DocLine("Returns:")
        List.parser
    }
}
