import Quick
import Nimble

@testable import HSDocKit

class TextDocumentSpec: QuickSpec {
    override func spec() {
        describe("TextDocument") {
            context("parser") {
                let parser = TextDocument.parser()
                
                it("parses a single line") {
                    var input = """
                    foobar
                    """[...]
                    
                    let result = parser.parse(&input)
                    expect(result).to(equal([
                        .init(1, text: "foobar")
                    ]))
                    
                    expect(input).to(haveCount(0))
                }
                
                it("parses multiple lines") {
                    var input = """
                    one
                    two
                    """[...]
                    
                    let result = parser.parse(&input)
                    
                    expect(result).to(equal([
                        .init(1, text: "one"),
                        .init(2, text: "two")
                    ]))
                    expect(input).to(haveCount(0))
                }
                
                it("parses blank lines") {
                    var input = "\n\n"[...]
                    
                    let result = parser.parse(&input)
                    
                    expect(result).to(equal([
                        .init(1, text: ""),
                        .init(2, text: ""),
                        .init(3, text: "")
                    ]))
                    expect(input).to(haveCount(0))
                }
            }
        }
    }
}
