import Parsing

extension BulletList {
    
    /// Parses a list of ``ListItem``s.
    static let parser = OneOrMore {
        BulletItem.parser
    } terminator: {
        blankDocLineOrEnd
    }
}
