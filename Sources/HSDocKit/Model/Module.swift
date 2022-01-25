
/// Defines a module of functions/methods/etc.
public class Module {
    /// The name of the ``Module``.
    public let name: ModuleSignature
    
    /// The documentation for the ``Module``.
    public let doc: ModuleDoc
    
    /// The list of fields defined for the module.
    public var fields: [FieldDoc] = []
    
    /// The list of functions defined for the module.
    public var functions: [FunctionDoc] = []
    
    /// The list of methods defined for the module.
    public var methods: [MethodDoc] = []
    
    /// The list of variables defined for the module.
    public var variables: [VariableSignature] = []
    
    /// Constructs a new `Module` with the specified name and documentation.
    ///
    /// - Parameters:
    ///   - doc: The documentation for the module.
    public init(doc: ModuleDoc) {
        self.name = doc.name
        self.doc = doc
    }
}
