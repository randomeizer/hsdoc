import Quick
import Nimble
import Parsing
import HSDocKit

class VerifySpec: QuickSpec {
    override func spec() {
        describe("Verify") {
            itParses(
                "nothing thrown",
                with: Rest().verify { _ in }
            ) {
                "Hello"
            } to: {
                "Hello"
            }
            
            itFailsParsing(
                "thrown",
                with: Rest().verify { _ in
                    throw LintError.expected("something else")
                }
            ) {
                "Hello"
            } withErrorMessage: {
                "expected something else"
            } leaving: {
                ""
            }
        }
    }
}
