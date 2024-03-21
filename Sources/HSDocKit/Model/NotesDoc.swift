/// The list of `Notes` for the item.
public struct NotesDoc: Equatable {
    /// The items in the list of notes.
    public let items: BulletList
    
    /// Creates a new `NotesDoc` with the specified list of items.
    /// - Parameter items: The items in the notes.
    public init(items: BulletList) {
        self.items = items
    }
    
    /// Creates a new `NotesDoc` with the specified list of items.
    /// - Parameters:
    ///   - head: The first item (required)
    ///   - tail: The remaining items (optional)
    public init(_ head: BulletItem, _ tail: BulletItem...) {
        var items = BulletList(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}

extension NotesDoc {
    func text(for prefix: Doc.Prefix) -> String {
        """
        \(prefix)
        \(prefix) Notes:
        \(items.text(for: prefix))
        """
    }
}
