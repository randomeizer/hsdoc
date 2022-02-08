import Parsing

// Parses an individual parameter, which may be optional if surrounded by `[]`.
extension ParameterSignature {
    /// Creates a parser to convert a `Substring` into a `ParameterSignature`
    /// - Returns: The parser.
    static func parser() -> AnyParser<Substring, ParameterSignature> {
        OneOf {
            Identifier.parser()
                .map { ParameterSignature(name: $0, isOptional: false) }
            Parse {
                "["
                Identifier.parser()
                "]"
            }.map { ParameterSignature(name: $0, isOptional: true)}
        }
        .eraseToAnyParser()
    }
    
    /// Creates a parser to convert a `Substring` with a bracketted "(list)" of parameter names.
    /// - Returns: The parser.
    static func listParser() -> AnyParser<Substring, [ParameterSignature]> {
        Parse {
            "("
            Skip { optionalSpaces }
            Many {
                ParameterSignature.parser()
            } separator: {
                commaSeparator
            } terminator: {
                Skip { optionalSpaces }
                ")"
            }
        }
        .eraseToAnyParser()
    }
}
