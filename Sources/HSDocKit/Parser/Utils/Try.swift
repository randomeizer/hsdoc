import Parsing

/// Allows you to try parsing, catching the error and either outputting an error (same or different), or
/// outputting an alternate `Upstream.Output` value. This could be hard-coded, or uses the error result, for example.
public struct Try<Upstream: Parser>: Parser {
    public let upstream: Upstream
    public let catcher: (Error) throws -> Upstream.Output
    
    public init(@ParserBuilder _ upstream: () -> Upstream, `catch` catcher: @escaping (Error) throws -> Upstream.Output) {
        self.upstream = upstream()
        self.catcher = catcher
    }
    
    public func parse(_ input: inout Upstream.Input) throws -> Upstream.Output {
        do {
            return try upstream.parse(&input)
        } catch {
            return try catcher(error)
        }
    }
}
