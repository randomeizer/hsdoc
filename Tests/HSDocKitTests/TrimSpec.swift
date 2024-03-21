import Quick
import Nimble
import Parsing
import HSDocKit

class TrimSpec: QuickSpec {
    override class func spec() {
        describe("Trim") {
            let parser = Trim { Prefix(0...) }
            
            itParses("empty string") {
                ""
            } with: {
                parser
            } to: {
                ""
            }
            
            itParses("spaces") {
                "     "
            } with: {
                parser
            } to: {
                ""
            }
            
            itParses("no spaces") {
                "foobar"
            } with: {
                parser
            } to: {
                "foobar"
            }
            
            itParses("left padded") {
                "   foobar"
            } with: {
                parser
            } to: {
                "foobar"
            }
            
            itParses("right padded") {
                "foobar   "
            } with: {
                parser
            } to: {
                "foobar"
            }
            
            itParses("padded") {
                "   foobar    "
            } with: {
                parser
            } to: {
                "foobar"
            }
            
            itParses("multiple words") {
                "   foo bar     "
            } with: {
                parser
            } to: {
                "foo bar"
            }
            
            itParses("tabs") {
                "\tfoobar\t"
            } with: {
                parser
            } to: {
                "foobar"
            }
            
            itParses("digit trimming") {
                "123foobar456"
            } with: {
                Trim(charactersIn: .decimalDigits) { Rest() }
            } to: {
                "foobar"
            }

        }
    }
}
