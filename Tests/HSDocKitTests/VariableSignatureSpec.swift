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
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:8
                    1 | foo.bar()
                      |        ^ expected end of input
                    """
                }
                
                itFailsParsing("method", with: parser) {
                    "foo:bar()"
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:4
                    1 | foo:bar()
                      |    ^ expected end of input
                    """
                }
            }
        }
    }
}
