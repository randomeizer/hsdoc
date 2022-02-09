import Quick
import Nimble
@testable import HSDocKit

class VariableSignatureSpec: QuickSpec {
    override func spec() {
        describe("VariableSignature") {
            context("parser") {
                let parser = VariableSignature.parser
                
                itParses("simple", with: parser) {
                    "foo.bar"
                } to: {
                    .init(module: .init("foo"), name: "bar", type: nil)
                }
                
                itParses("typed", with: parser) {
                    "foo.bar <table>"
                } to: {
                    .init(module: .init("foo"), name: "bar", type: "<table>")
                }
                
                itParses("trailing space", with: parser) {
                    "foo.bar "
                } to: {
                    .init(module: .init("foo"), name: "bar", type: nil)
                }

                
                itFailsParsing("function", with: parser) {
                    "foo.bar()"
                }
                
                itFailsParsing("method", with: parser) {
                    "foo:bar()"
                }
            }
        }
    }
}
