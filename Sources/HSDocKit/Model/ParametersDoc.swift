
/// Describes the parameters of a function or method.
public struct ParametersDoc: Equatable {
    /// The list of parameter items.
    public let items: List
    
    /// Constructs a new `ParametersDoc` with the specified list of `ListItem`s.
    ///
    /// - Parameter items: The list of `ListItem`s describing the parameters.
    public init(items: List) {
        self.items = items
    }
    
    public init(_ head: ListItem, _ tail: ListItem...) {
        var items = List(head)
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
