import Parsing

/// Parses a `Void` result if the next input matches the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
struct Require<Upstream>: Parser where Upstream: Parser {
    let upstream: Upstream
    
    /// Construct a ``Require`` with the provided `Upstream` ``Parser``.
    ///
    /// - Parameter upstream: The ``Parser`` to check.
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    /// Construct a ``Require`` with the provided `Upstream` ``ParserBuilder`` closure.
    ///
    /// Parameter build: The `Upstream` ``Parser``-returning closure.
    @inlinable
    init(@ParserBuilder _ build: () -> Upstream) {
      self.upstream = build()
    }
    
    @inlinable
    func parse(_ input: inout Upstream.Input) -> Void? {
      let original = input
      if self.upstream.parse(&input) != nil {
        input = original
        return ()
      }
      return nil
    }
}
