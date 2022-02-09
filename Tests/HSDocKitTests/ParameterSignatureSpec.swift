import Quick
import Nimble
@testable import HSDocKit

class ParameterSignatureSpec: QuickSpec {
    override func spec() {
        describe("ParameterSignature") {
            context("parser") {
                let parser = ParameterSignature.parser
                
                itParses("required", with: parser) {
                    "foo"
                } to: {
                    .init(name: "foo", isOptional: false)
                }
                
                itParses("optional", with: parser) {
                    "[foo]"
                } to: {
                    .init(name: "foo", isOptional: true)
                }
                
                itFailsParsing("unclosed optional", with: parser) { "[foo" }
                
                itParses("unopened optional", with: parser) {
                    "foo]"
                } to: {
                    .init(name: "foo", isOptional: false)
                } leaving: {
                    "]"
                }
                
                itParses("full", with: parser) {
                    "_foo123"
                } to: {
                    .init(name: "_foo123", isOptional: false)
                }
                
                itFailsParsing("number", with: parser) { "123_foo" }
                
                it("is described correctly") {
                    expect(ParameterSignature(name: "foo", isOptional: false).description).to(equal("foo"))
                    expect(ParameterSignature(name: "foo", isOptional: true).description).to(equal("[foo]"))
                }
                
                context("list") {
                    let parser = ParameterSignature.listParser
                    
                    itParses("empty", with: parser, from: "()", to: [], leaving: "")
                    
                    itParses("one", with: parser) {
                        "(foo)"
                    } to: {
                        [.init(name: "foo")]
                    }
                    
                    itParses("two", with: parser) {
                        "(foo, bar)"
                    } to: {
                        [.init(name: "foo"), .init(name: "bar")]
                    }
                    
                    itParses("optional", with: parser) {
                        "([foo])"
                    } to: {
                        [.init(name: "foo", isOptional: true)]
                    }
                    
                    itParses("mixed", with: parser) {
                        "(foo, [bar])"
                    } to: {
                        [.init(name: "foo"), .init(name: "bar", isOptional: true)]
                    }
                    
                    itFailsParsing("extra comma", with: parser) {
                        "(foo,)"
                    }
                }
            }
        }
    }
}
