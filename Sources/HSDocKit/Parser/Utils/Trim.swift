import Foundation
import Parsing

extension CharacterSet {
    @usableFromInline
    func containsUnicodeScalars(of character: Character) -> Bool {
        return character.unicodeScalars.allSatisfy(contains(_:))
    }
}

/// Trims the `Substring` contents
public struct Trim<Upstream: Parser>: Parser
where Upstream.Input == Substring,
      Upstream.Output == Substring
{
    public typealias Input = Substring
    public typealias Output = Substring
    
    public let characterSet: CharacterSet
    public let upstream: Upstream
    
    @inlinable
    public init(charactersIn characterSet: CharacterSet = CharacterSet.whitespaces, @ParserBuilder<Upstream.Input> upstream: () -> Upstream) {
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
