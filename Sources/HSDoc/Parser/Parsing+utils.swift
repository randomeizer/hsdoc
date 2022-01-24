import Parsing

/// Parses a `Void` result if the next input does not match the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
struct Not<Upstream>: Parser where Upstream: Parser {
    let upstream: Upstream
    
    /// Construct a ``Not`` with the provided `Upstream` ``Parser``.
    ///
    /// - Parameter upstream: The ``Parser`` to check.
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    /// Construct a ``Not`` with the provided `Upstream` ``ParserBuilder`` closure.
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
        return nil
      }
      return ()
    }
}

/// Parses and returns result if the next input matches the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
struct Peek<Upstream>: Parser where Upstream: Parser {
    let upstream: Upstream
    
    /// Construct a ``Peek`` with the provided `Upstream` ``Parser``.
    ///
    /// - Parameter upstream: The ``Parser`` to check.
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    /// Construct a ``Peek`` with the provided `Upstream` ``ParserBuilder`` closure.
    ///
    /// Parameter build: The `Upstream` ``Parser``-returning closure.
    @inlinable
    init(@ParserBuilder _ build: () -> Upstream) {
      self.upstream = build()
    }
    
    @inlinable
    func parse(_ input: inout Upstream.Input) -> Upstream.Output? {
      let original = input
      if let result = self.upstream.parse(&input) {
        input = original
        return result
      }
      return nil
    }
}

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
