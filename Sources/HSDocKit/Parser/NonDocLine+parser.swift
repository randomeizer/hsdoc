import Parsing

struct NonDocLine: Parser {
    func parse(_ input: inout TextDocument) throws {
        guard let firstLine = input.first else {
            throw LintError.expected("at least one line")
        }
        
        var text = firstLine.text
        
        try Not { docPrefix }.parse(&text)
        
        input = input.dropFirst()
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
