import Parsing

extension List {
    
    /// Parses a list of ``ListItem``s.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, List> {
        OneOrMore {
            ListItem.parser()
        }
        .eraseToAnyParser()
    }
}
