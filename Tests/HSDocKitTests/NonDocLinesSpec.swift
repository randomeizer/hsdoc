import Quick
import Nimble
@testable import HSDocKit

class NonDocLinesSpec: QuickSpec {
    override class func spec() {
        describe("NonDocLines") {
            let parser = NonDocLines()
            
            itParses("two lines") {
                TextDocument {
                    """
                    line 1
                    line 2
                    --- line 3
                    """
                }
            } with: {
                parser
            } to: {
                2
            } leaving: {
                TextDocument(firstLine: 3) {
                    "--- line 3"
                }
            }
            
            itParses("doc lines") {
                TextDocument {
                    "--- doc line"
                }
            } with: {
                parser
            } to: {
                0
            } leaving: {
                TextDocument {
                    "--- doc line"
                }
            }
        }
    }
}
