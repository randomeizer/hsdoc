import Parsing

/// A collection of ``Doc`` values.
public typealias Docs = [DocBlock]

extension Docs {
    /// Parses a ``Docs`` value from a ``Substring``
    public static let parser = Many {
        DocBlock.parser
    }
}
