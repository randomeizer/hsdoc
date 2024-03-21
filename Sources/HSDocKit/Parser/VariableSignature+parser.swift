import Parsing

extension ConstantSignature {
    /// Parses a ``ConstantSignature`` from a ``Substring``.
    static let parser = Parse(ConstantSignature.init) {
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
