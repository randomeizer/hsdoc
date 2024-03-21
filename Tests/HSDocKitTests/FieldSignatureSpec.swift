import Quick
import Nimble
@testable import HSDocKit

class FieldSignatureSpec: QuickSpec {
    override class func spec() {
        describe("FieldSignature") {
            context("parser") {
                let parser = FieldSignature.parser
                
                itParses("simple") {
                    "foo.bar"[...]
                } with: {
                    parser
                } to: {
                    FieldSignature(module: .init("foo"), name: "bar", type: nil)
                }
                
                itParses("typed") {
                    "foo.bar <table>"[...]
                } with: {
                    parser
                } to: {
                    FieldSignature(module: .init("foo"), name: "bar", type: "<table>")
                }
                
                itFailsParsing("function") {
                    "foo.bar()"[...]
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
                    "()"[...]
                }
                
                itFailsParsing("method") {
                    "foo:bar()"[...]
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:4
                    1 | foo:bar()
                      |    ^ expected "."
                    """
                } leaving: {
                    ":bar()"
                }
            }
        }
    }
}
