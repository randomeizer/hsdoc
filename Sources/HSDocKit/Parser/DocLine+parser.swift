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
    func parse(_ input: inout TextDocument) throws -> Upstream.Output {
        guard let firstLine = input.first else {
            throw ParsingError.expectedInput("at least one line required", at: input)
        }
        
        var text = firstLine.text
        
        let _ = try docPrefix.parse(&text)
        let result = try upstream.parse(&text)
        
        guard text.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw ParsingError.expectedInput("non-whitespace characters", at: text)
        }
        
        input = input.dropFirst()
        return result
    }
}
