import Quick
import Nimble
@testable import HSDocKit

class NonDocLinesSpec: QuickSpec {
    override func spec() {
        describe("NonDocLines") {
            let parser = NonDocLines()
            
            itParses("two lines", with: parser) {
                TextDocument {
                    """
                    line 1
                    line 2
                    --- line 3
                    """
                }
            } to: {
                2
            } leaving: {
                TextDocument(firstLine: 3) {
                    "--- line 3"
                }
            }
            
            itParses("doc lines", with: parser) {
                TextDocument {
                    "--- doc line"
                }
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
