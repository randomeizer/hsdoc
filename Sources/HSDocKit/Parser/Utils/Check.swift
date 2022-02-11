import Parsing

/// Parses a `Void` result if the next input matches the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
public struct Check<Upstream>: Parser where Upstream: Parser {
    /// The upstream ``Parser`` to check.
    public let upstream: Upstream
    
    public let fail: (Error, inout Upstream.Input) -> Error

    /// Construct a ``Check`` with the provided `Upstream` ``ParserBuilder`` closure.
    ///
    /// Parameter build: The `Upstream` ``Parser``-returning closure.
    @inlinable
    public init(@ParserBuilder _ build: () -> Upstream, orThrow fail: @escaping (Error, inout Upstream.Input) -> Error = { (error, _) in error }) {
        self.upstream = build()
        self.fail = fail
    }

    @inlinable
    public func parse(_ input: inout Upstream.Input) throws {
        var i = input
        do {
            _ = try self.upstream.parse(&i)
        } catch {
            throw fail(error, &i)
        }
    }
}

extension Check {
    @inlinable
    public init(@ParserBuilder _ build: () -> Upstream, orThrow fail: @escaping () -> Error) {
        self.init(build) { _, _ in
            fail()
        }
    }

    @inlinable
    public init(@ParserBuilder _ build: () -> Upstream, orThrow fail: @escaping (inout Upstream.Input) -> Error) {
        self.init(build) { _, input in
            fail(&input)
        }
    }
}
