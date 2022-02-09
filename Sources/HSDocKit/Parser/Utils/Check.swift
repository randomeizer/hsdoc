import Parsing

/// Parses a `Void` result if the next input matches the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
struct Check<Upstream>: Parser where Upstream: Parser {
    /// The upstream ``Parser`` to check.
    let upstream: Upstream
    
    let fail: (Error, inout Upstream.Input) -> Error

    /// Construct a ``Check`` with the provided `Upstream` ``Parser``.
    ///
    /// - Parameter upstream: The ``Parser`` to check.
    @inlinable
    init(_ upstream: Upstream, or fail: @escaping (Error, inout Upstream.Input) -> Error = { (error, _) in error }) {
        self.upstream = upstream
        self.fail = fail
    }

    /// Construct a ``Check`` with the provided `Upstream` ``ParserBuilder`` closure.
    ///
    /// Parameter build: The `Upstream` ``Parser``-returning closure.
    @inlinable
    init(@ParserBuilder _ build: () -> Upstream, orThrow fail: @escaping (Error, inout Upstream.Input) -> Error = { (error, _) in error }) {
        self.upstream = build()
        self.fail = fail
    }

    @inlinable
    func parse(_ input: inout Upstream.Input) throws {
        var i = input
        do {
            _ = try self.upstream.parse(&i)
        } catch {
            throw fail(error, &i)
        }
    }
}
