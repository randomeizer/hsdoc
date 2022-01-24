import Parsing

extension VariableSignature {
    /// Parses a ``VariableSignature`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, VariableSignature> {
        Parse(VariableSignature.init) {
            Optionally {
                ModuleSignature.prefixParser()
                "."
            }
            Identifier.parser()
            Optionally {
                Skip(oneOrMoreSpaces)
                Prefix(1...).map(VariableType.init)
            }
            Skip(optionalSpaces)
            End()
        }
        .eraseToAnyParser()
    }
}
