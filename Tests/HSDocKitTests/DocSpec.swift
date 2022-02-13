import Quick
import Nimble
import CustomDump
@testable import HSDocKit

class DocSpec: QuickSpec {
    override func spec() {
        describe("Doc") {
            context("module") {
                let parser = Doc.moduleParser
                
                itParses("module with docs", with: parser) {
                    TextDocument {
                    """
                    --- === foo.bar ===
                    ---
                    --- Details.
                    """
                    }
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
