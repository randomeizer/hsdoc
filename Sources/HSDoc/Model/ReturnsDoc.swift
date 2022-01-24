/// Describes the return values of a function or method.
public struct ReturnsDoc: Equatable {

    /// The list of `ListItem`s describing the return values.
    public let items: List
    
    /// Constructs a new `ReturnsDoc` with the specified list of `ListItem`s.
    ///
    /// - Parameter items: The list of `ListItem`s describing the return values.
    public init(items: List) {
        self.items = items
    }
    
    /// Constructs a new `ReturnsDoc` with the specified list of `ListItem`s.
    ///
    /// - Parameters:
    ///   - head: The first `ListItem`.
    ///   - tail: Additional `ListItem`s.
    public init(_ head: ListItem, _ tail: ListItem...) {
        var items = List(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}
