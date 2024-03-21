import Foundation
import Parsing
import NonEmpty

/// Requires at least one match for the `Upstream` ``Parser``. If found, a ``NonEmpty`` array of the results is the `Output`.
struct OneOrMore<Input, Output, Upstream: Parser, Separator: Parser, Terminator: Parser>: Parser
where Input == Upstream.Input, Output == Upstream.Output,
      Upstream.Input == Separator.Input,
      Terminator.Input == Upstream.Input
{
    let upstream: Upstream
    let separator: Separator
    let terminator: Terminator

    init(
        @ParserBuilder<Upstream.Input> _ build: () -> Upstream,
        @ParserBuilder<Separator.Input> separator: () -> Separator,
        @ParserBuilder<Terminator.Input> terminator: () -> Terminator
    ) {
        self.upstream = build()
        self.separator = separator()
        self.terminator = terminator()
    }

    @inlinable
    func parse(_ input: inout Upstream.Input) throws -> NonEmpty<[Upstream.Output]> {
        let original = input
        var rest = input
        #if DEBUG
            var previous = input
        #endif

        var values = [Upstream.Output]()
        var loopError: Error?

        while true {
            let output: Upstream.Output
            do {
                output = try upstream.parse(&input)
            } catch {
                loopError = error
                break
            }
            #if DEBUG
                defer { previous = input }
            #endif
            values.append(output)
            rest = input
            do {
                _ = try separator.parse(&input)
            } catch {
                loopError = error
                break
            }

            #if DEBUG
                if memcmp(&input, &previous, MemoryLayout<Upstream.Input>.size) == 0 {
                    var description = ""
                    debugPrint(output, terminator: "", to: &description)
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
        input = rest
        do {
            _ = try self.terminator.parse(&input)
        } catch {
            throw loopError ?? error
        }

        guard let result = NonEmpty(rawValue: values) else {
            defer { input = original }
            throw LintError.expected("one or more values")
        }
        return result
    }
}

extension OneOrMore where Separator == Always<Input, Void>, Terminator == Always<Input, Void> {
    @inlinable
    init(@ParserBuilder<Upstream.Input> _ builder: () -> Upstream) {
        self.upstream = builder()
        self.separator = .init(())
        self.terminator = .init(())
    }
}

extension OneOrMore where Separator == Always<Input, Void> {
    @inlinable
    init(@ParserBuilder<Terminator.Input> _ builder: () -> Upstream, terminator: () -> Terminator) {
        self.upstream = builder()
        self.separator = .init(())
        self.terminator = terminator()
    }
}

extension OneOrMore where Terminator == Always<Input, Void> {
    @inlinable
    init(@ParserBuilder<Separator.Input> _ builder: () -> Upstream, separator: () -> Separator) {
        self.upstream = builder()
        self.separator = separator()
        self.terminator = .init(())
    }
}
