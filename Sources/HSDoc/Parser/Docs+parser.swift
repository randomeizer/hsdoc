import Parsing

extension Docs {
    /// Parses a ``Docs`` value from a ``Substring``
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, Docs> {
        Parse {
            Many {
                Skip(nonDocLines)
                Doc.parser()
            }
            Skip(nonDocLines)
        }
        .eraseToAnyParser()
    }
}
