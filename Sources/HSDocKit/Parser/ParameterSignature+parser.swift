import Parsing

// Parses an individual parameter, which may be optional if surrounded by `[]`.
extension ParameterSignature {
    /// A parser that convert a `Substring` into a `ParameterSignature`
    static let parser = OneOf {
        Parse {
            "["
            Identifier.parser
            "]"
        }.map { ParameterSignature(name: $0, isOptional: true) }
        Identifier.parser
            .map { ParameterSignature(name: $0, isOptional: false) }
    }

    /// A parser that converts a `Substring` with a bracketted `"(list)"` of parameter names.
    static let listParser = Parse {
        "("
        Skip { optionalSpaces }
        Many {
            ParameterSignature.parser
        } separator: {
            commaSeparator
        } terminator: {
            Skip { optionalSpaces }
            ")"
        }
    }
    .eraseToAnyParser()
}
