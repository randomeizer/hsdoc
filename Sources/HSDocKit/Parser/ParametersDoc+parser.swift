import Parsing

extension ParametersDoc {
    /// Parses a ``ParametersDoc`` value from a ``Substring``.
    static let parser = Parse(ParametersDoc.init(items:)) {
        Require {
            blankDocLine
        } orThrow: {
            LintError.expected("blank line before Parameters")
        }
        DocLine("Parameters:")
        List.parser
    }
}
