import Quick
import Nimble
@testable import HSDocKit

class VariableSignatureSpec: QuickSpec {
    override class func spec() {
        describe("VariableSignature") {
            context("parser") {
                let parser = VariableSignature.parser
                
                itParses("simple") {
                    "foo.bar"[...]
                } with: {
                    parser
                } to: {
                    VariableSignature(module: .init("foo"), name: "bar", type: nil)
                }
                
                itParses("typed") {
                    "foo.bar <table>"
                } with: {
                    parser
                } to: {
                    .init(module: .init("foo"), name: "bar", type: "<table>")
                }
                
                itParses("trailing space") {
                    "foo.bar "
                } with: {
                    parser
                } to: {
                    .init(module: .init("foo"), name: "bar", type: nil)
                }

                
                itFailsParsing("function") {
                    "foo.bar()"
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:8
                    1 | foo.bar()
                      |        ^ expected end of input
                    """
                } leaving: {
                    "()"
                }
                
                itFailsParsing("method") {
                    "foo:bar()"
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:4
                    1 | foo:bar()
                      |    ^ expected end of input
                    """
                } leaving: {
                    ":bar()"
                }
            }
        }
    }
}
