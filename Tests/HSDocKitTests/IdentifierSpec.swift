import Quick
import Nimble
@testable import HSDocKit

class IdentifierSpec: QuickSpec {
    override func spec() {
        describe("Identifier") {
            context("parser") {
                let parser = Identifier.parser
                
                itParses("alphas", with: parser) {
                    "foo"
                } to: {
                    .init("foo")
                }
                
                itParses("underscore", with: parser) {
                    "_foo"
                } to: {
                    .init("_foo")
                }
                
                itParses("alphanumeric", with: parser) {
                    "abc123"
                } to: {
                    .init("abc123")
                }
                
                itFailsParsing("numericalpha", with: parser) {
                    "123abc"
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
