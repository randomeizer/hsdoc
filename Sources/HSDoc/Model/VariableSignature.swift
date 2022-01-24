
/// Defines the signature for a variable.
public struct VariableSignature: Equatable {
    /// The optional module name.
    public let module: ModuleSignature?
    
    /// The name of the variable.
    public let name: Identifier

    /// The optional type of the variable.
    public let type: VariableType?
    
    public init(module: ModuleSignature? = nil, name: Identifier, type: VariableType? = nil) {
        self.module = module
        self.name = name
        self.type = type
    }
}

extension VariableSignature: CustomStringConvertible {
    /// The variable signature as a string.
    public var description: String {
        let moduleDoc = module == nil ? "" : "\(module!)."
        
        if let type = type {
            return "\(moduleDoc)\(name) \(type)"
        } else {
            return "\(moduleDoc)\(name)"
        }
    }
}
