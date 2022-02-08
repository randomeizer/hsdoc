import Parsing

extension MethodSignature {
    /// Parses a ``MethodSignature`` from a ``Substring``.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, MethodSignature> {
        Parse(MethodSignature.init) {
            Parse {
                ModuleSignature.prefixParser()
                ":"
            }
            Identifier.parser()
            ParameterSignature.listParser()
            Skip { optionalSpaces }
            Optionally {
                "->"
                Skip { optionalSpaces }
                ReturnSignature.listParser()
            }
            End()
        }
        .eraseToAnyParser()
    }
}
