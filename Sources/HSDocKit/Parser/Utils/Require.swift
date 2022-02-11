import Parsing

/// Attempts to parse the `upstream` ``Parser``. If it fails, the `or` closure
/// is called, allowing the error to be handled and transformed into a new ``Error``.
public struct Require<Upstream>: Parser
where Upstream: Parser
{
    public let upstream: Upstream
    public let fail: (Error, inout Upstream.Input) -> Error
    
    @inlinable
    public init(@ParserBuilder _ upstream: () -> Upstream, orThrow fail: @escaping (Error, inout Upstream.Input) -> Error) {
        self.upstream = upstream()
        self.fail = fail
    }
    
    @inlinable
    public func parse(_ input: inout Upstream.Input) throws -> Upstream.Output {
        do {
            return try upstream.parse(&input)
        } catch {
            throw fail(error, &input)
        }
    }
}

extension Require {
    @inlinable
    public init(@ParserBuilder _ upstream: () -> Upstream, orThrow fail: @escaping (inout Upstream.Input) -> Error) {
        self.init(upstream) { _, input in
            fail(&input)
        }
    }
    
    @inlinable
    public init(@ParserBuilder _ upstream: () -> Upstream, orThrow fail: @escaping () -> Error) {
        self.init(upstream) { _, _ in
            fail()
        }
    }
}
