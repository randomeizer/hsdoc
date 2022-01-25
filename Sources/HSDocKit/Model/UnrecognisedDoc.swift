/// Collects any unparsed 'documentation comment' (`///` or `///`) lines to be reported.
/// Note: This should be checked for last, since it will match any block of lines
/// starting with the document comment marker.
public struct UnrecognisedDoc: Equatable {
    public let lines: Lines
    
    public init(lines: Lines) {
        self.lines = lines
    }
    
    public init(_ head: String, _ tail: String...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.lines = lines
    }
}
