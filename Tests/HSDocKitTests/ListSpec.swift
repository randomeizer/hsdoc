import Quick
import Nimble
@testable import HSDocKit

class ListSpec: QuickSpec {
    override class func spec() {
        describe("List") {
            let parser = BulletList.parser
            
            itParses("single item") {
                TextDocument {
                """
                ---  * list item
                """
                }
            } with: {
                parser
            } to: {
                BulletList(
                    .init("list item")
                )
            }
            
            itParses("two items") {
                TextDocument {
                """
                ---  * list item
                ---  * another item
                """
                }
            } with: {
                parser
            } to: {
                BulletList(
                    .init("list item"),
                    .init("another item")
                )
            }
            
            itParses("multiline items") {
                TextDocument {
                """
                ---  * list item
                ---    with second line
                ---  * another item
                ---    with second line
                """
                }
            } with: {
                parser
            } to: {
                BulletList(
                    .init(
                        "list item",
                        "with second line"
                    ),
                    .init(
                        "another item",
                        "with second line"
                    )
                )
            }
            
            itParses("sub-items") {
                TextDocument {
                """
                ---  * list item
                ---    * sub-item 1
                ---    * sub-item 2
                ---      with second line
                ---  * another item
                ---    * sub-item 3
                ---    * sub-item 4
                """
                }
            } with: {
                parser
            } to: {
                BulletList(
                    BulletItem(
                        lines: .init("list item"),
                        items: .init(
                            .init("sub-item 1"),
                            .init(
                                "sub-item 2",
                                "with second line"
                            )
                        )
                    ),
                    BulletItem(
                        lines: .init("another item"),
                        items: .init(
                            .init("sub-item 3"),
                            .init("sub-item 4")
                        )
                    )
                )
            }
            
            itFailsParsing("unindented second line") {
                TextDocument {
                """
                ---  * item 1
                ---  second line
                ---  * item 2
                """
                }
            } with: {
                parser
            } withErrorMessage: {
                """
                error: unexpected input
                 --> input:2:6-16
                2 | ---  second line
                  |      ^^^^^^^^^^^ expected "*"
                """
            } leaving: {
                TextDocument(firstLine: 2) {
                """
                ---  second line
                ---  * item 2
                """
                }
            }
        }
    }
}
