import NonEmpty

/// Defines a module of functions/methods/etc.
public class Module {
    public typealias Description = NonEmpty<[ParagraphDoc]>
    
    /// The name of the ``Module``.
    public let name: ModuleSignature
    
    /// The documentation for the ``Module``.
    public let description: Description
    
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
    public init(name: ModuleSignature, description: Description) {
        self.name = name
        self.description = description
    }
}
