import Parsing

// Parses documentation comment prefixes, including a single optional space.
let docPrefix = Parse {
    OneOf {
        Parse { // Lua
            "---"
            Not { "-" }
        }
        Parse { // ObjC
            "///"
            Not { "/" }
        }
    }
    Skip { optionalSpace }
}

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
            throw LintError.expected("at least one line required")
        }
        
        var text = firstLine.text
        
        _ = try docPrefix.parse(&text)
        let result = try upstream.parse(&text)
        
        guard text.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw LintError.expected("non-whitespace characters")
        }
        
        input = input.dropFirst()
        return result
    }
}

// Parses at least one blank documentation line ("///")
let blankDocLines = Skip {
    OneOrMore { DocLine("") }
}
