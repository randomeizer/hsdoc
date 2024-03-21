import Parsing

extension MethodSignature {
    /// Parses a ``MethodSignature`` from a ``Substring``.
    static let parser = Parse(MethodSignature.init) {
        Parse {
            ModuleSignature.prefixParser
            ":"
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
    .eraseToAnyParser()
}
