import Parsing

extension FieldSignature {
    /// Parses a ``FieldSignature`` from a ``Substring``.
    static let parser = Parse(FieldSignature.init) {
        ModuleSignature.prefixParser()
        "."
        Identifier.parser
        Optionally {
            Skip { oneOrMoreSpaces }
            Rest().map(FieldType.init)
        }
        End()
    }
}
