
/// Defines the documentation for a field.
public struct FieldDoc: Equatable {
    /// The signature of the field.
    public let signature: FieldSignature

    /// The description of the field.
    public let description: DescriptionDoc

    /// The notes for the field.
    public let notes: NotesDoc?
    
    /// Constructs a new `FieldDoc` with the specified signature, description, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the field.
    ///   - description: The description of the field.
    ///   - notes: The notes for the field.
    public init(
        signature: FieldSignature,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    ) {
        self.signature = signature
        self.description = description
        self.notes = notes
    }
}
