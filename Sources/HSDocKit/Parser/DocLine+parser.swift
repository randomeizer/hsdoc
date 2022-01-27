import Parsing

/// Parses a single 'documentation' comment line, starting with `///` or `---` and ending with a newline
/// The `Upstream` ``Parser`` will only be passed the contents of a single line, excluding the header and the newline.
/// It must consume the whole contents of the line, other than trailing whitespace.
struct DocLine<Upstream>: Parser
where Upstream: Parser, Upstream.Input == Substring
{
    let upstream: Upstream
    
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    @inlinable
    init(@ParserBuilder upstream: () -> Upstream) {
        self.upstream = upstream()
    }
    
    @inlinable
    func parse(_ input: inout TextDocument) -> Upstream.Output? {
        guard let firstLine = input.first else {
            return nil
        }
        
        var text = firstLine.text
        
        guard docPrefix.parse(&text) != nil else {
            return nil
        }
        
        guard let result = upstream.parse(&text) else {
            return nil
        }
        
        guard text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
        
        input = input.dropFirst()
        return result
    }
}
