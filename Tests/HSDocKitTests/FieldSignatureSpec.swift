import Quick
import Nimble
@testable import HSDocKit

class FieldSignatureSpec: QuickSpec {
    override func spec() {
        describe("FieldSignature") {
            context("parser") {
                let parser = FieldSignature.parser
                
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
