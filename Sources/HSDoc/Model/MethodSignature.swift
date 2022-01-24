/// Defines the signature for a function.
public struct MethodSignature : Equatable {
    public let module: ModuleSignature
    public let name: Identifier
    public let parameters: [ParameterSignature]
    public let returns: [ReturnSignature]?
    
    public init(
        module: ModuleSignature,
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

extension MethodSignature: CustomStringConvertible {
    public var description: String {
        let main = "\(module):\(name)(\(parameters.map {String(describing: $0) } .joined(separator: ", ")))"
        guard let returns = returns else {
            return main
        }
        return "\(main) -> \(returns.map { String(describing: $0) } .joined(separator: ", "))"
    }
}
