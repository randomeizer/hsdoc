/// Describes the return values of a function or method.
public struct ReturnsDoc: Equatable {

    /// The list of `ListItem`s describing the return values.
    public let items: BulletList
    
    /// Constructs a new `ReturnsDoc` with the specified list of `BulletItem`s.
    ///
    /// - Parameter items: The list of `BulletItem`s describing the return values.
    public init(items: BulletList) {
        self.items = items
    }
    
    /// Constructs a new `ReturnsDoc` with the specified list of `BulletItem`s.
    ///
    /// - Parameters:
    ///   - head: The first `BulletItem`.
    ///   - tail: Additional `BulletItem`s.
    public init(_ head: BulletItem, _ tail: BulletItem...) {
        var items = BulletList(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}

extension ReturnsDoc {
    func text(for prefix: Doc.Prefix) -> String {
        """
        \(prefix)
        \(prefix) Returns:
        \(items.text(for: prefix))
        """
    }
}
