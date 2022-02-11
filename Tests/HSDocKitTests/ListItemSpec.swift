import Quick
import Nimble
@testable import HSDocKit

class ListItemSpec: QuickSpec {
    override func spec() {
        describe("ListItem") {
            context("parser") {
                let parser = ListItem.parser
                
                itParses("simple list item", with: parser) {
                    TextDocument {
                    """
                    ---  * a list item.
                    """
                    }
                } to: {
                    ListItem("a list item."[...])
                }
                
                itParses("multi-line list item", with: parser) {
                    TextDocument {
                    """
                    ---  * a list item
                    ---    with multiple lines
                    """
                    }
                } to: {
                    ListItem(
                        "a list item",
                        "with multiple lines"
                    )
                }
                
                itParses("sub-items", with: parser) {
                    TextDocument {
                    """
                    ---  * a list item
                    ---    * a sub-item
                    """
                    }
                } to: {
                    ListItem(
                        lines: .init("a list item"),
                        items: .init(
                            .init("a sub-item")
                        ))
                }
                
                itParses("sub-sub-items", with: parser) {
                    TextDocument {
                    """
                    ---  * a list item
                    ---    * a sub-item
                    ---      * a sub-sub item
                    ---    * another sub-item
                    ---  * another item
                    """
                    }
                } to: {
                    ListItem(
                        lines: .init("a list item"),
                        items: .init(
                            .init(
                                lines: .init("a sub-item"),
                                items: .init(.init("a sub-sub item"))
                            ),
                            .init("another sub-item")
                        )
                    )
                } leaving: {
                    TextDocument(firstLine: 5) {
                    """
                    ---  * another item
                    """
                    }
                }
                
                itParses("no spaces", with: parser) {
                    TextDocument {
                    """
                    --- * a list item
                    """
                    }
                } to: {
                    ListItem("a list item")
                }
                
                itFailsParsing("excess indenting", with: parser) {
                    TextDocument {
                    """
                    ---   * a list item
                    """
                    }
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:6
                    1 | ---   * a list item
                      |      ^ expected "*"
                    """
                }
                
                itParses("insufficient indent for second line", with: parser) {
                    TextDocument {
                    """
                    ---  * a list item
                    ---  second line
                    """
                    }
                } to: {
                    ListItem("a list item")
                } leaving: {
                    TextDocument(firstLine: 2) {
                    """
                    ---  second line
                    """
                    }
                }
            }
        }
    }
}
