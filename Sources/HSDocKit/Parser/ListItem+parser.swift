import Parsing

extension ListItem {
    /// Creates a `Parser` for list items.
    /// - Returns: The `Parser`.
    static func parser() -> Parsers.ListItemParser {
        .init()
    }
}

extension Parsers {
    /// Parses a 'list item' line, along with any following lines which are sub-elements of the item, due to indentation.
    struct ListItemParser: Parser
    {
        func parse(_ input: inout Substring) -> ListItem? {
            var inputCopy = input
            let listItemFirstLine = DocLine {
                optionalSpaces
                "* "
                Rest()
            }

            guard let (inset, body) = listItemFirstLine.parse(&inputCopy) else {
                return nil
            }
            
            let subLineParser = Many {
                DocLine {
                    Skip(String(inset))
                    Not("*")
                    Rest().map(String.init)
                }
            }
            guard let subLines = subLineParser.parse(&inputCopy) else {
                return nil
            }
            
            var lines = Lines(String(body))
            lines.append(contentsOf: subLines)
            
            input = inputCopy
            return ListItem(lines: lines)
        }
    }
}
