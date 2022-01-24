
/// Defines the documentation for a function.
public struct MethodDoc: Equatable {
    /// The signature of the method.
    public let signature: MethodSignature

    /// The description of the method.
    public let description: DescriptionDoc

    /// The parameters of the method.
    public let parameters: ParametersDoc

    /// The return values of the method.
    public let returns: ReturnsDoc

    /// The notes for the method.
    public let notes: NotesDoc?
    
    /// Constructs a new `MethodDoc` with the specified signature, description, parameters, return values, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the method.
    ///   - description: The description of the method.
    ///   - parameters: The parameters of the method.
    ///   - returns: The return values of the method.
    ///   - notes: The notes for the method.
    public init(
        signature: MethodSignature,
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
