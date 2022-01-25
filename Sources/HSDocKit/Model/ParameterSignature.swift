/// A Named parameter in the signature.
public struct ParameterSignature: Equatable {
    /// The name of the argument.
    public let name: Identifier
    
    /// If true, the argument is optional.
    public let isOptional: Bool
    
    /// Constructs a new `ParameterSignature` with the specified name and optional flag.
    ///
    /// - Parameters:
    ///   - name: The name of the argument.
    ///   - isOptional: If `true`, the argument is optional.
    public init(name: Identifier, isOptional: Bool = false) {
        self.name = name
        self.isOptional = isOptional
    }
}

extension ParameterSignature: CustomStringConvertible {
    public var description: String {
        if isOptional {
            return "[\(name)]"
        } else {
            return String(describing: name)
        }
    }
}
