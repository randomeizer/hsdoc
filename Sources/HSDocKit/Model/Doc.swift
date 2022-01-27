/// Defines the options for documentation segments.
public enum Doc: Equatable {
    case module(
        name: ModuleSignature,
        description: DescriptionDoc
    )
    
    case function(
        signature: FunctionSignature,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    )
    
    case variable(
        signature: VariableSignature,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    )
    
    case method(
        signature: MethodSignature,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    )
    
    case field(
        signature: FieldSignature,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    )
    
    case unrecognised(
        lines: Lines
    )
}
