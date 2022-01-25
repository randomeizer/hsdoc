/// Represents a single return value for a function or method.
public struct ReturnSignature: Equatable {
    public let value: String
    
    /// Constructs a new `ReturnSignature` with the specified value.
    ///
    /// - Parameter value: The return value.
    public init(_ value: String) {
        self.value = value
    }
}

extension ReturnSignature: CustomStringConvertible {
    /// Compact `String` description of the `ReturnSignature`.
    public var description: String { value }
}

extension ReturnSignature: ExpressibleByStringLiteral {
    /// Allows the `ReturnSignature` to be initialized with a string literal.
    public init(stringLiteral: String) {
        self.value = stringLiteral
    }
}
