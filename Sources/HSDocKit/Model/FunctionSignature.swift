
/// Defines the signature for a function.
public struct FunctionSignature : Equatable {
    /// The optional module for the function.
    public let module: ModuleSignature?
    
    /// The name of the function
    public let name: Identifier

    /// The parameters of the function.
    public let parameters: [ParameterSignature]

    /// The return value(s) of the function.
    public let returns: [ReturnSignature]?
    
    public var fullName: String {
        if let module = module {
            return "\(module).\(name)"
        } else {
            return String(describing: name)
        }
    }
    
    /// Constructs a new `FunctionSignature` with the specified name, parameters, and return values.
    ///
    /// - Parameters:
    ///   - module: The optional module of the function.
    ///   - name: The name of the function.
    ///   - parameters: The parameters of the function.
    ///   - returns: The return values of the function.
    public init(
        module: ModuleSignature? = nil,
        name: Identifier,
        parameters: [ParameterSignature] = [],
        returns: [ReturnSignature]? = nil
    ) {
        self.module = module
        self.name = name
        self.parameters = parameters
        self.returns = returns
    }
}

extension FunctionSignature: CustomStringConvertible {
    public var description: String {
        let moduleDesc = module == nil ? "" : "\(module!)."
        let main = "\(moduleDesc)\(name)(\(parameters.map {String(describing: $0) } .joined(separator: ", ")))"
        guard let returns = returns else {
            return main
        }
        return "\(main) -> \(returns.map { String(describing: $0) } .joined(separator: ", "))"
    }
}
