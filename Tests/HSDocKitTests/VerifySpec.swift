import Quick
import Nimble
import Parsing
import HSDocKit

class VerifySpec: QuickSpec {
    override class func spec() {
        describe("Verify") {
            itParses("when nothing is thrown") {
                "Hello"[...]
            } with: {
                Rest().verify { _ in }
            } to: {
                "Hello"[...]
            }
            
            itFailsParsing("when an error is thrown") {
                "Hello"[...]
            } with: {
                Rest().verify { _ in
                    throw LintError.expected("something else")
                }
            } withErrorMessage: {
                "expected something else"
            } leaving: {
                ""[...]
            }
        }
    }
}
