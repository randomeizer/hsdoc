import Foundation
import Parsing
import NonEmpty

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

/// Requires at least one match for the `Upstream` ``Parser``. If found, a ``NonEmpty`` array of the results is the `Output`.
struct OneOrMore<Upstream, Separator>: Parser
where Upstream: Parser,
      Separator: Parser,
      Upstream.Input == Separator.Input
{
    let upstream: Upstream
    let separator: Separator
    
    init(_ upstream: Upstream, separator: Separator) {
        self.upstream = upstream
        self.separator = separator
    }
    
    init(
        @ParserBuilder _ build: () -> Upstream,
        @ParserBuilder separator: () -> Separator
    ) {
        self.upstream = build()
        self.separator = separator()
    }
    
    @inlinable
    func parse(_ input: inout Upstream.Input) -> NonEmpty<[Upstream.Output]>? {
        let original = input
        var rest = input
        #if DEBUG
          var previous = input
        #endif

        var values = [Upstream.Output]()
        
        while let parsed = upstream.parse(&input) {
            #if DEBUG
              defer { previous = input }
            #endif

            values.append(parsed)
            rest = input
            if separator.parse(&input) == nil {
                break
            }
            #if DEBUG
              if memcmp(&input, &previous, MemoryLayout<Upstream.Input>.size) == 0 {
                var description = ""
                debugPrint(parsed, terminator: "", to: &description)
                breakpoint(
                  """
                  ---
                  A "OneOrMore" parser succeeded in parsing a value of "\(Upstream.Output.self)" \
                  (\(description)), but no input was consumed.

                  This is considered a logic error that leads to an infinite loop, and is typically \
                  introduced by parsers that always succeed, even though they don't consume any input. \
                  This includes "Prefix" and "CharacterSet" parsers, which return an empty string when \
                  their predicate immediately fails.

                  To work around the problem, require that some input is consumed (for example, use \
                  "Prefix(minLength: 1)"), or introduce a "separator" parser to "OneOrMore".
                  ---
                  """
                )
              }
            #endif
        }
        
        guard let result = NonEmpty(rawValue: values) else {
            input = original
            return nil
        }
        input = rest
        return result
    }
}

extension OneOrMore where Separator == Always<Input, Void> {
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
        self.separator = .init(())
    }
    
    @inlinable
    init(@ParserBuilder _ builder: () -> Upstream) {
        self.upstream = builder()
        self.separator = .init(())
    }
}
