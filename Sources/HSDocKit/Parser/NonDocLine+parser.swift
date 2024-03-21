import Parsing

struct NonDocLine: Parser {
    func parse(_ input: inout TextDocument) throws {
        guard let firstLine = input.first else {
            throw LintError.expected("at least one line")
        }
        
        var text = firstLine.text
        
        do {
            _ = try docPrefix.parse(&text)
        } catch {
            input = input.dropFirst()
            return
        }
        
        throw LintError.expected("not to have a documentation prefix")
    }
}

struct NonDocLines: Parser {
    func parse(_ input: inout TextDocument) -> UInt {
        let nonDocLine = NonDocLine()
        var count: UInt = 0
        
        while !input.isEmpty {
            do {
                try nonDocLine.parse(&input)
                count = count + 1
            } catch {
                break
            }
        }
        
        return count
    }
}
