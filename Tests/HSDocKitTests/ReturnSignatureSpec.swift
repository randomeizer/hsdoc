import Quick
import Nimble
@testable import HSDocKit

class ReturnSignatureSpec: QuickSpec {
    override func spec() {
        describe("ReturnSignature") {
            context("parser") {
                let parser = ReturnSignature.parser()
                
                itParses("something", with: parser, from: "foo", to: .init("foo"))
                itFailsParsing("nothing", with: parser, from: "")
                itFailsParsing("blank line", with: parser, from: "\n")
                
                context("list") {
                    let parser = ReturnSignature.listParser()
                    
                    itParses("nothing", with: parser, from: "", to: [])
                    
                    itParses("one", with: parser) {
                        "foo"
                    } to: {
                        [ReturnSignature("foo")]
                    }
                    
                    itParses("two", with: parser) {
                        "foo, bar"
                    } to: {
                        ["foo", "bar"]
                    }
                    
                    itParses("alternate", with: parser) {
                        "foo, bar | nil"
                    } to: {
                        ["foo", "bar | nil"]
                    }
                    
                    itParses("trimming whitespace", with: parser) {
                        " foo , bar \t"
                    } to: {
                        ["foo", "bar"]
                    }
                }
            }
        }
    }
}
