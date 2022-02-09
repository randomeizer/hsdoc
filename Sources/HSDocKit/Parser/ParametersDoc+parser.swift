import Parsing

extension ParametersDoc {
    /// Parses a ``ParametersDoc`` value from a ``Substring``.
    static let parser = Parse(ParametersDoc.init(items:)) {
        DocLine("Parameters:")
        List.parser
    }
}
