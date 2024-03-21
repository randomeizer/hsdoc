import Parsing

extension Parser {
    @inlinable
    public func verify(_ check: @escaping (Output) throws -> Void) -> Parsers.Verify<Input, Output, Self> {
        .init(self, check: check)
    }
}

extension Parsers {
    public struct Verify<Input, Output, Upstream: Parser>: Parser
    where Input == Upstream.Input, Output == Upstream.Output
    {
        public let upstream: Upstream
        
        public let check: (Upstream.Output) throws -> Void
        
        public init(_ upstream: Upstream, check: @escaping (Upstream.Output) throws -> Void) {
            self.upstream = upstream
            self.check = check
        }
        
        public init(@ParserBuilder<Upstream.Input> _ builder: () -> Upstream, check: @escaping (Upstream.Output) throws -> Void) {
            self.upstream = builder()
            self.check = check
        }
        
        public func parse(_ input: inout Upstream.Input) throws -> Upstream.Output {
            let result = try upstream.parse(&input)
            try check(result)
            return result
        }
    }
}
