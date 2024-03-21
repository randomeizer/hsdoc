@testable import HSDocKit
import Nimble
import Quick

class ReturnSignatureSpec: QuickSpec {
    override class func spec() {
        describe("ReturnSignature") {
            context("parser") {
                let parser = ReturnSignature.parser

                itParses("something") {
                    "foo"
                } with: {
                    parser
                } to: {
                    .init("foo")
                }

                itFailsParsing("nothing") {
                    ""
                } with: {
                    parser
                } withErrorMessage: {
                    "expected a return type"
                }

                itFailsParsing("blank line") {
                    "\n"
                } with: {
                    parser
                } withErrorMessage: {
                    "expected a return type"
                }
            }

            context("listParser") {
                let parser = ReturnSignature.listParser

                itParses("nothing") {
                    ""
                } with: {
                    parser
                } to: {
                    []
                }

                itParses("one") {
                    "foo"
                } with: {
                    parser
                } to: {
                    [ReturnSignature("foo")]
                }

                itParses("two") {
                    "foo, bar"
                } with: {
                    parser
                } to: {
                    ["foo", "bar"]
                }

                itParses("alternate") {
                    "foo, bar | nil"
                } with: {
                    parser
                } to: {
                    ["foo", "bar | nil"]
                }

                itParses("trimming whitespace") {
                    " foo , bar \t"
                } with: {
                    parser
                } to: {
                    ["foo", "bar"]
                }
            }
        }
    }
}
