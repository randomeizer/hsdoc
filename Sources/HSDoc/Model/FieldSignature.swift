/// Defines the signature for a field.
public struct FieldSignature: Equatable {
    /// The module name.
    public let module: ModuleSignature
    
    /// The name of the field.
    public let name: Identifier

    /// The optional type of the field.
    public let type: FieldType?
}

extension FieldSignature: CustomStringConvertible {
    /// The field signature as a string.
    public var description: String {
        if let type = type {
            return "\(module).\(name) \(type)"
        } else {
            return "\(module).\(name)"
        }
    }
}
