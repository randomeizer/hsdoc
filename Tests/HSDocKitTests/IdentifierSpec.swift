import Quick
import Nimble
@testable import HSDocKit

class IdentifierSpec: QuickSpec {
    override class func spec() {
        describe("Identifier") {
            context("parser") {
                let parser = Identifier.parser
                
                itParses("alphas") {
                    "foo"[...]
                } with: {
                    parser
                } to: {
                    .init("foo")
                }
                
                itParses("underscore") {
                    "_foo"
                } with: {
                    parser
                } to: {
                    .init("_foo")
                }
                
                itParses("alphanumeric") {
                    "abc123"
                } with: {
                    parser
                } to: {
                    .init("abc123")
                }
                
                itFailsParsing("numericalpha") {
                    "123abc"
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: expected letter or underscore
                     --> input:1:1
                    1 | 123abc
                      | ^
                    """
                }
            }
        }
    }
}
