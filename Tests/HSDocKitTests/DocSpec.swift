import Quick
import Nimble
import CustomDump
@testable import HSDocKit

class DocSpec: QuickSpec {
    override class func spec() {
        describe("Doc") {
            context("module") {
                let parser = Doc.moduleParser
                
                itParses("module with docs") {
                    TextDocument {
                    """
                    --- === foo.bar ===
                    ---
                    --- Details.
                    """
                    }
                } with: {
                    parser
                } to: {
                    Doc.module(
                        name: .init("foo", "bar"),
                        details: .init(.init("Details."))
                    )
                }
            }
        }
    }
}
