import Parsing

extension List {
    
    /// Parses a list of ``ListItem``s.
    static let parser = OneOrMore {
        ListItem.parser
    } terminator: {
        blankDocLineOrEnd
    }
}
