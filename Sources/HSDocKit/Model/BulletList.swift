import NonEmpty

/// A list of `BulletItem`s with at least one item.
public typealias BulletList = NonEmpty<[BulletItem]>

extension BulletList {
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
