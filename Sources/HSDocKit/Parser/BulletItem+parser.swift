import Parsing

extension BulletItem {
    /// Creates a `Parser` for list items.
    static let parser = Parsers.BulletItemParser()
}

extension Parsers {
    /// Parses a 'list item' line, along with any following lines which are sub-elements of the item, due to indentation.
    struct BulletItemParser: Parser
    {
        public let indent: String
        
        public init(indent: String = "") {
            self.indent = indent
        }
        
        func parse(_ input: inout TextDocument) throws -> BulletItem {
            var inputCopy = input
            let listItemFirstLine = DocLine {
                Skip { indent }
                optionalSpace
                "*"
                oneOrMoreSpaces
                Rest()
            }

            let (pre, post, body) = try listItemFirstLine.parse(&inputCopy)
            let internalIndent = "\(indent)\(pre) \(post)"
            let subLineParser = Many {
                DocLine {
                    internalIndent
                    Not { "*" }
                    Rest()
                }
            }
            
            let subItemParser = Optionally {
                OneOrMore {
                    Self(indent: internalIndent)
                }
            }
            
            let subLines = try subLineParser.parse(&inputCopy)
            let subItems = subItemParser.parse(&inputCopy)
            
            var lines = Lines(body)
            lines.append(contentsOf: subLines)
            
            input = inputCopy
            return BulletItem(lines: lines, items: subItems)
        }
    }
}
