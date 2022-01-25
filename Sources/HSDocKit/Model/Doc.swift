/// Defines the options for documentation segments.
public enum Doc: Equatable {
    case module(ModuleDoc)
    case function(FunctionDoc)
    case variable(VariableDoc)
    case method(MethodDoc)
    case field(FieldDoc)
    case unrecognised(UnrecognisedDoc)
}
