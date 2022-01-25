/// The list of `Notes` for the item.
public struct NotesDoc: Equatable {
    /// The items in the list of notes.
    public let items: List
    
    /// Creates a new `NotesDoc` with the specified list of items.
    /// - Parameter items: The items in the notes.
    public init(items: List) {
        self.items = items
    }
    
    /// Creates a new `NotesDoc` with the specified list of items.
    /// - Parameters:
    ///   - head: The first item (required)
    ///   - tail: The remaining items (optional)
    public init(_ head: ListItem, _ tail: ListItem...) {
        var items = List(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}
