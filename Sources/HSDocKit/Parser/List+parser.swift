import Parsing

extension List {
    
    /// Parses a list of ``ListItem``s.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, List> {
        Many(atLeast: 1) {
            ListItem.parser()
        }
        .map {
            precondition(!$0.isEmpty)
            return List($0)!
        }
        .eraseToAnyParser()
    }
}
