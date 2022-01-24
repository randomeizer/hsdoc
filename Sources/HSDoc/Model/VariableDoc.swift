/// Defines the documentation for a variable.
public struct VariableDoc: Equatable {
    /// The signature of the variable.
    public let signature: VariableSignature

    /// The description of the variable.
    public let description: DescriptionDoc

    /// The notes for the variable.
    public let notes: NotesDoc?
    
    /// Constructs a new `VariableDoc` with the specified signature, description, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the variable.
    ///   - description: The description of the variable.
    ///   - notes: The notes for the variable.
    public init(
        signature: VariableSignature,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    ) {
        self.signature = signature
        self.description = description
        self.notes = notes
    }
}
