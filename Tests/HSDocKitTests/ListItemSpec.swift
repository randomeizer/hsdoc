import Quick
import Nimble
@testable import HSDocKit

class ListItemSpec: QuickSpec {
    override class func spec() {
        describe("BulletItem") {
            context("parser") {
                let parser = BulletItem.parser
                
                itParses("simple list item") {
                    TextDocument {
                    """
                    ---  * a list item.
                    """
                    }
                } with: {
                    parser
                } to: {
                    BulletItem("a list item."[...])
                }
                
                itParses("multi-line list item") {
                    TextDocument {
                    """
                    ---  * a list item
                    ---    with multiple lines
                    """
                    }
                } with: {
                    parser
                } to: {
                    BulletItem(
                        "a list item",
                        "with multiple lines"
                    )
                }
                
                itParses("sub-items") {
                    TextDocument {
                    """
                    ---  * a list item
                    ---    * a sub-item
                    """
                    }
                } with: {
                    parser
                } to: {
                    BulletItem(
                        lines: .init("a list item"),
                        items: .init(
                            .init("a sub-item")
                        ))
                }
                
                itParses("sub-sub-items") {
                    TextDocument {
                    """
                    ---  * a list item
                    ---    * a sub-item
                    ---      * a sub-sub item
                    ---    * another sub-item
                    ---  * another item
                    """
                    }
                } with: {
                    parser
                } to: {
                    BulletItem(
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
                
                itParses("no spaces") {
                    TextDocument {
                    """
                    --- * a list item
                    """
                    }
                } with: {
                    parser
                } to: {
                    BulletItem("a list item")
                }
                
                itFailsParsing("excess indenting") {
                    TextDocument {
                    """
                    ---   * a list item
                    """
                    }
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:6
                    1 | ---   * a list item
                      |      ^ expected "*"
                    """
                }
                
                itParses("insufficient indent for second line") {
                    TextDocument {
                    """
                    ---  * a list item
                    ---  second line
                    """
                    }
                } with: {
                    parser
                } to: {
                    BulletItem("a list item")
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
