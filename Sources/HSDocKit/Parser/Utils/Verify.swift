import Parsing

extension Parser {
    @inlinable
    public func verify(_ check: @escaping (Output) throws -> Void) -> Parsers.Verify<Self> {
        .init(self, check: check)
    }
}

extension Parsers {
    public struct Verify<Upstream: Parser>: Parser {
        public let upstream: Upstream
        
        public let check: (Upstream.Output) throws -> Void
        
        public init(_ upstream: Upstream, check: @escaping (Upstream.Output) throws -> Void) {
            self.upstream = upstream
            self.check = check
        }
        
        public init(@ParserBuilder _ builder: () -> Upstream, check: @escaping (Upstream.Output) throws -> Void) {
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
