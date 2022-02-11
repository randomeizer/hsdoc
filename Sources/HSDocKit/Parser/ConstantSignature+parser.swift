import Parsing

extension VariableSignature {
    /// Parses a ``VariableSignature`` from a ``Substring``.
    static let parser = Parse(VariableSignature.init) {
        Optionally {
            ModuleSignature.prefixParser
            "."
        }
        Identifier.parser
        Optionally {
            Skip { oneOrMoreSpaces }
            Prefix(1...)
        }
        Skip { optionalSpaces }
        End()
    }
}
