import Parsing

extension ListItem {
    /// Creates a `Parser` for list items.
    static let parser = Parsers.ListItemParser()
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
                    Rest()
                }
            }
            
            let subLines = try subLineParser.parse(&inputCopy)
            
            var lines = Lines(body)
            lines.append(contentsOf: subLines)
            
            input = inputCopy
            return ListItem(lines: lines)
        }
    }
}
