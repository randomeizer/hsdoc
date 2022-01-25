import Parsing

extension ParametersDoc {
    /// Parses a ``ParametersDoc`` value from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, ParametersDoc> {
        Parse(ParametersDoc.init(items:)) {
            blankDocLines
            DocLine("Parameters:")
            List.parser()
        }
        .eraseToAnyParser()
    }
}
