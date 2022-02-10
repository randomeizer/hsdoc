import Foundation
import Parsing

extension CharacterSet {
    @usableFromInline
    func containsUnicodeScalars(of character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}

/// Trims the `Substring` contents
public struct Trim<Upstream>: Parser
where Upstream: Parser, Upstream.Input == Substring, Upstream.Output == Substring
{
    public let characterSet: CharacterSet
    public let upstream: Upstream
    
    @inlinable
    public init(charactersIn characterSet: CharacterSet = CharacterSet.whitespaces, @ParserBuilder upstream: () -> Upstream) {
        self.characterSet = characterSet
        self.upstream = upstream()
    }
    
    @inlinable
    public func parse(_ input: inout Upstream.Input) throws -> Upstream.Output {
        func untrimmed(_ char: Character) -> Bool {
            !characterSet.containsUnicodeScalars(of: char)
        }
        
        let output = try upstream.parse(&input)
        
        guard let start = output.firstIndex(where: untrimmed(_:)),
              let end = output.lastIndex(where: untrimmed(_:))
        else {
            return input
        }
        
        return output[start...end]
    }
}
