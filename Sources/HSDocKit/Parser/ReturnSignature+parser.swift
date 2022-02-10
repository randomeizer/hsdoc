import Parsing

// Parses function/method return values
extension ReturnSignature {
    
    /// Parses a single return signature value.
    public static let parser = Require {
        Trim {
            Prefix(1...) { !",\n".contains($0) }
        }
    } orThrow: { (_, _) in
        LintError.expected("a return type")
    }
    .map(ReturnSignature.init)
    
    /// Parses a list of return signature values.
    public static let listParser = Many {
        parser
    } separator: {
        commaSeparator
    }
}
