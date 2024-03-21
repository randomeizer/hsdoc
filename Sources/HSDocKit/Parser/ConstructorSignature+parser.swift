import Parsing

extension ConstructorSignature {
    /// Parses a ``ConstructorSignature`` from a ``Substring``
    static let parser = Parse(ConstructorSignature.init(module:name:parameters:returns:)) {
        Optionally {
            ModuleSignature.prefixParser
            "."
        }
        Identifier.parser
        ParameterSignature.listParser
        Skip { optionalSpaces }
        Optionally {
            "->"
            Skip { optionalSpaces }
            ReturnSignature.listParser
        }
        End()
    }
}
