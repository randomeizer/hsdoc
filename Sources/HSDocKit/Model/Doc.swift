/// Defines the options for documentation segments.
public enum Doc: Equatable {
    case module(
        name: ModuleSignature,
        description: DescriptionDoc
    )
    
    case function(
        signature: FunctionSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    )
    
    case variable(
        signature: VariableSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    )
    
    case method(
        signature: MethodSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    )
    
    case field(
        signature: FieldSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    )
    
    case unrecognised(
        lines: Lines
    )
}
