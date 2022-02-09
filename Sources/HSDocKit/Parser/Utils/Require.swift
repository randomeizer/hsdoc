import Parsing

/// Attempts to parse the `upstream` ``Parser``. If it fails, the `or` closure
/// is called, allowing the error to be handled and transformed into a new ``Error``.
struct Require<Upstream, Err>: Parser
where Upstream: Parser,
      Err: Error
{
    let upstream: Upstream
    let fail: (inout Upstream.Input, Error) -> Err
    
    init(@ParserBuilder _ upstream: () -> Upstream, or fail: () -> (inout Upstream.Input, Error) -> Err) {
        self.upstream = upstream()
        self.fail = fail()
    }
    
    func parse(_ input: inout Upstream.Input) throws -> Upstream.Output {
        do {
            return try upstream.parse(&input)
        } catch {
            throw fail(&input, error)
        }
    }
}
