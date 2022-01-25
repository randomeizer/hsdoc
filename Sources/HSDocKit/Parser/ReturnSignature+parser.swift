import Parsing

// Parses function/method return values
extension ReturnSignature {
    
    /// Parses a single return signature value.
    /// - Returns: The parser.
    public static func parser() -> AnyParser<Substring, ReturnSignature> {
        Prefix(1...) { !",\n".contains($0) }
        .map { ReturnSignature(String($0.trimmingCharacters(in: .whitespaces))) }
        .eraseToAnyParser()
    }
    
    /// Parses a list of return signature values.
    /// - Returns: The parser.
    public static func listParser() -> AnyParser<Substring, [ReturnSignature]> {
        Many {
            Self.parser()
        } separator: {
            commaSeparator
        }
        .eraseToAnyParser()
    }
}
