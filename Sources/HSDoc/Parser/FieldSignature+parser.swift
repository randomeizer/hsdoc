import Parsing

extension FieldSignature {
    /// Parses a ``FieldSignature`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, FieldSignature> {
        Parse(FieldSignature.init) {
            ModuleSignature.prefixParser()
            "."
            Identifier.parser()
            Optionally {
                Skip(oneOrMoreSpaces)
                Rest().map(FieldType.init)
            }
            End()
        }
        .eraseToAnyParser()
    }
}
