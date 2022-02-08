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
        func parse(_ input: inout TextDocument) throws -> ListItem {
            var inputCopy = input
            let listItemFirstLine = DocLine {
                optionalSpaces
                "* "
                Rest()
            }

            let (inset, body) = try listItemFirstLine.parse(&inputCopy)
            
            let subLineParser = Many {
                DocLine {
                    Skip { String(inset) }
                    Not { "*" }
                    Rest().map(String.init)
                }
            }
            
            let subLines = try subLineParser.parse(&inputCopy)
            
            var lines = Lines(String(body))
            lines.append(contentsOf: subLines)
            
            input = inputCopy
            return ListItem(lines: lines)
        }
    }
}
