import Quick
import Nimble
@testable import HSDocKit

class ListSpec: QuickSpec {
    override func spec() {
        describe("List") {
            let parser = BulletList.parser
            
            itParses("single item", with: parser) {
                TextDocument {
                """
                ---  * list item
                """
                }
            } to: {
                BulletList(
                    .init("list item")
                )
            }
            
            itParses("two items", with: parser) {
                TextDocument {
                """
                ---  * list item
                ---  * another item
                """
                }
            } to: {
                BulletList(
                    .init("list item"),
                    .init("another item")
                )
            }
            
            itParses("multiline items", with: parser) {
                TextDocument {
                """
                ---  * list item
                ---    with second line
                ---  * another item
                ---    with second line
                """
                }
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
            
            itParses("sub-items", with: parser) {
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
            
            itFailsParsing("unindented second line", with: parser) {
                TextDocument {
                """
                ---  * item 1
                ---  second line
                ---  * item 2
                """
                }
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
