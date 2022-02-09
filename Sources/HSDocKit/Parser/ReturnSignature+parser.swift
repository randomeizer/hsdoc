import Parsing

// Parses function/method return values
extension ReturnSignature {
    
    /// Parses a single return signature value.
    public static let parser = Require {
        Prefix(1...) { !",\n".contains($0) }
        .map { ReturnSignature(String($0.trimmingCharacters(in: .whitespaces))) }
    } orThrow: { (_, _) in
        LintError.expected("the return type")
    }
    
    /// Parses a list of return signature values.
    public static let listParser = Many {
        parser
    } separator: {
        commaSeparator
    }
}
