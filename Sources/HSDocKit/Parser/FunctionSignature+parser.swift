import Parsing

extension FunctionSignature {
    /// Parses a ``FunctionSignature`` from a ``Substring``
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, FunctionSignature> {
        Parse(FunctionSignature.init(module:name:parameters:returns:)) {
            Optionally {
                ModuleSignature.prefixParser()
                "."
            }
            Identifier.parser()
            ParameterSignature.listParser()
            Skip(optionalSpaces)
            Optionally {
                "->"
                Skip(optionalSpaces)
                ReturnSignature.listParser()
            }
            End()
        }
        .eraseToAnyParser()
    }
}
