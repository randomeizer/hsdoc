import NonEmpty

/// A list of `ListItem`s with at least one item.
public typealias List = NonEmpty<[ListItem]>

extension List {
    func text(for prefix: Doc.Prefix) -> String {
        let separator = "\(prefix)  * "
        
        var result = ""
        
        for item in self {
            if !result.isEmpty {
                result.append("\n")
            }
            result.append("\(separator)\(item.text(for: prefix))")
        }
        
        return result
    }
}
