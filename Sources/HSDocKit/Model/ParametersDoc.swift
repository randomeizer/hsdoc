
/// Describes the parameters of a function or method.
public struct ParametersDoc: Equatable {
    /// The list of parameter items.
    public let items: BulletList
    
    /// Constructs a new `ParametersDoc` with the specified list of `BulletItem`s.
    ///
    /// - Parameter items: The list of `BulletItem`s describing the parameters.
    public init(items: BulletList) {
        self.items = items
    }
    
    public init(_ head: BulletItem, _ tail: BulletItem...) {
        var items = BulletList(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}

extension ParametersDoc {
    func text(for prefix: Doc.Prefix) -> String {
        """
        \(prefix)
        \(prefix) Parameters:
        \(items.text(for: prefix))
        """
    }
}
