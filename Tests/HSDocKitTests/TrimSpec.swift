import Quick
import Nimble
import Parsing
import HSDocKit

class TrimSpec: QuickSpec {
    override func spec() {
        describe("Trim") {
            let parser = Trim { Rest() }
            
            itParses("empty string", with: parser) {
                ""
            } to: {
                ""
            }
            
            itParses("spaces", with: parser) {
                "     "
            } to: {
                ""
            }
            
            itParses("no spaces", with: parser) {
                "foobar"
            } to: {
                "foobar"
            }
            
            itParses("left padded", with: parser) {
                "   foobar"
            } to: {
                "foobar"
            }
            
            itParses("right padded", with: parser) {
                "foobar   "
            } to: {
                "foobar"
            }
            
            itParses("padded", with: parser) {
                "   foobar    "
            } to: {
                "foobar"
            }
            
            itParses("multiple words", with: parser) {
                "   foo bar     "
            } to: {
                "foo bar"
            }
            
            itParses("tabs", with: parser) {
                "\tfoobar\t"
            } to: {
                "foobar"
            }
            
            itParses("digit trimming", with: Trim(charactersIn: .decimalDigits) { Rest() }) {
                "123foobar456"
            } to: {
                "foobar"
            }

        }
    }
}
