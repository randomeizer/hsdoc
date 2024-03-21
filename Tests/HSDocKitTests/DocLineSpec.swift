@testable import HSDocKit
import Nimble
import Parsing
import Quick

class DocLineSpec: QuickSpec {
    override class func spec() {
        describe("DocLine") {
            let parser = DocLine(Prefix(0...))

            itParses("parses a Lua comment line") {
                TextDocument { "--- Foo" }
            } with: {
                parser
            } to: {
                "Foo"
            }

            itParses("a blank Lua comment line") {
                TextDocument { "---\n" }
            } with: {
                parser
            } to: {
                ""
            } leaving: {
                TextDocument(firstLine: 2, content: "")
            }

            itParses("an ObjC comment line") {
                TextDocument { "/// Foo\n" }
            } with: {
                parser
            } to: {
                "Foo"
            } leaving: {
                TextDocument(firstLine: 2) { "" }
            }

            itParses("when the input ends without a newline") {
                TextDocument { "/// Foo" }
            } with: {
                parser
            } to: {
                "Foo"
            } leaving: {
                TextDocument()
            }


            it("passes on leading and trailing whitespace") {
                let parser = DocLine(Rest())
                var input = TextDocument { "///   abc  " }
                expect(try parser.parse(&input)).to(equal("  abc  "))
                expect(input).to(equal(TextDocument()))
            }
            
            itParses("on leading and trailing whitespace") {
                TextDocument { "///   abc  " }
            } with: {
                parser
            } to: {
                "  abc  "
            } leaving: {
                TextDocument()
            }

        }
    }
}
