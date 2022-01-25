
/// Defines the documentation for a function.
public struct FunctionDoc: Equatable {
    /// The signature of the function.
    public let signature: FunctionSignature

    /// The description of the function.
    public let description: DescriptionDoc

    /// The parameters of the function.
    public let parameters: ParametersDoc

    /// The return values of the function.
    public let returns: ReturnsDoc

    /// The notes for the function.
    public let notes: NotesDoc?
    
    /// Constructs a new `FunctionDoc` with the specified signature, description, parameters, return values, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function.
    ///   - description: The description of the function.
    ///   - parameters: The parameters of the function.
    ///   - returns: The return values of the function.
    ///   - notes: The notes for the function.
    public init(
        signature: FunctionSignature,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    ) {
        self.signature = signature
        self.description = description
        self.parameters = parameters
        self.returns = returns
        self.notes = notes
    }
}
