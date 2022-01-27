
/// Defines a module of functions/methods/etc.
public class Module {
    /// The name of the ``Module``.
    public let name: ModuleSignature
    
    /// The documentation for the ``Module``.
    public let description: DescriptionDoc
    
    /// The list of fields defined for the module.
    public var fields: [Doc] = []
    
    /// The list of functions defined for the module.
    public var functions: [Doc] = []
    
    /// The list of methods defined for the module.
    public var methods: [Doc] = []
    
    /// The list of variables defined for the module.
    public var variables: [Doc] = []
    
    /// Constructs a new `Module` with the specified name and documentation.
    ///
    /// - Parameters:
    ///   - doc: The documentation for the module.
    public init(name: ModuleSignature, description: DescriptionDoc) {
        self.name = name
        self.description = description
    }
}
