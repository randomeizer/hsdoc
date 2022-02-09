import Quick
import Nimble
import Parsing
@testable import HSDocKit

class DocLineSpec: QuickSpec {
    override func spec() {
        context("DocLine") {
            it("parses a Lua comment line") {
                let parser = DocLine(Rest())
                var input = TextDocument { "--- Foo" }
                expect(try parser.parse(&input)).to(equal("Foo"))
                expect(input).to(haveCount(0))
            }
            
            it("parses a blank Lua comment line") {
                let parser = DocLine(Rest())
                var input = TextDocument { "---\n"  }
                expect(try parser.parse(&input)).to(equal(""))
                expect(input).to(equal(TextDocument(firstLine: 2) { "" }))
            }
            
            it("parses a ObjC comment line") {
                let parser = DocLine(Rest())
                var input = TextDocument { "/// Foo\n" }
                expect(try parser.parse(&input)).to(equal("Foo"))
                expect(input).to(equal(TextDocument(firstLine: 2) { "" } ))
            }
            
            it("parses when the input ends without a newline") {
                let parser = DocLine(Rest())
                var input = TextDocument { "/// Foo" }
                expect(try parser.parse(&input)).to(equal("Foo"))
                expect(input).to(equal(TextDocument()))
            }
            
            it("passes on leading and trailing whitespace") {
                let parser = DocLine(Rest())
                var input = TextDocument { "///   abc  " }
                expect(try parser.parse(&input)).to(equal("  abc  "))
                expect(input).to(equal(TextDocument()))
            }
        }
    }
}
