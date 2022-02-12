import Quick
import Nimble
import CustomDump

@testable import HSDocKit

class TextSpec: QuickSpec {
    override func spec() {
        describe("text") {
            context("BulletItem") {
                it("outputs a single line") {
                    let value = BulletItem("one")
                    
                    expect(value.text(for: .lua)).to(equal(
                        "one"
                    ))
                }
                
                it("outputs multiple lines") {
                    let value = BulletItem(
                        "one", "two", "three"
                    )
                    
                    expect(value.text(for: .lua)).to(equal(
                        """
                        one
                        ---    two
                        ---    three
                        """
                    ))
                }
            }
            
            context("List") {
                it("outputs a single one line item") {
                    let value = BulletList(
                        BulletItem("one")
                    )
                    
                    expect(value.text(for: .lua)).to(equal(
                        """
                        ---  * one
                        """
                    ))
                }
                
                it("outputs a single multiline item") {
                    let value = BulletList(
                        BulletItem("one", "two", "three")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---  * one
                        ---    two
                        ---    three
                        """
                    )
                }
                
                it("outputs a multiple singleline items") {
                    let value = BulletList(
                        BulletItem("one"),
                        BulletItem("two"),
                        BulletItem("three")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---  * one
                        ---  * two
                        ---  * three
                        """
                    )
                }
                
                it("outputs a multiple multiline items") {
                    let value = BulletList(
                        BulletItem("alpha", "beta"),
                        BulletItem("one", "two"),
                        BulletItem("three")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---  * alpha
                        ---    beta
                        ---  * one
                        ---    two
                        ---  * three
                        """
                    )
                }
            }
            
            context("DescriptionDoc") {
                it("outputs a single line") {
                    let value = DescriptionDoc(
                        "one"
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        --- one
                        """
                    )
                }
                
                it("outputs multiple lines") {
                    let value = DescriptionDoc(
                        .init("one", "two")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        --- one
                        --- two
                        """
                    )
                }
            }
            
            context("ParametersDoc") {
                it("outputs a single return value") {
                    let value = ParametersDoc(
                        BulletItem("one")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---
                        --- Parameters:
                        ---  * one
                        """
                    )
                }
                
                it("outputs multiple return values") {
                    let value = ParametersDoc(
                        BulletItem("one"),
                        BulletItem("two")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---
                        --- Parameters:
                        ---  * one
                        ---  * two
                        """
                    )
                }
            }
            
            context("ReturnsDoc") {
                it("outputs a single return value") {
                    let value = ReturnsDoc(
                        BulletItem("one")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---
                        --- Returns:
                        ---  * one
                        """
                    )
                }
                
                it("outputs multiple return values") {
                    let value = ReturnsDoc(
                        BulletItem("one"),
                        BulletItem("two")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---
                        --- Returns:
                        ---  * one
                        ---  * two
                        """
                    )
                }
            }
            
            context("NotesDoc") {
                it("outputs a single return value") {
                    let value = NotesDoc(
                        BulletItem("one")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---
                        --- Notes:
                        ---  * one
                        """
                    )
                }
                
                it("outputs multiple return values") {
                    let value = NotesDoc(
                        BulletItem("one"),
                        BulletItem("two")
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        ---
                        --- Notes:
                        ---  * one
                        ---  * two
                        """
                    )
                }
            }
            
            context("Doc.function") {
                it("outputs a simple value") {
                    let value = Doc.function(
                        signature: .init(name: "one"),
                        deprecated: false,
                        description: .init("Description"),
                        parameters: .init(.init("None")),
                        returns: .init(.init("Nothing")),
                        notes: nil
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        --- one()
                        --- Function
                        --- Description
                        ---
                        --- Parameters:
                        ---  * None
                        ---
                        --- Returns:
                        ---  * Nothing
                        """
                    )
                }
                
                it("outputs a complex value") {
                    let value = Doc.function(
                        signature: .init(
                            module: .init("foo", "bar"),
                            name: "one",
                            parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                            returns: ["string", "boolean"]
                        ),
                        deprecated: true,
                        description: .init("Description that goes", "over two lines."),
                        parameters: .init(
                            .init("a - required param"),
                            .init("b - optional param")
                        ),
                        returns: .init(
                            .init("a string"),
                            .init("`true` if successful")
                        ),
                        notes: .init(
                            .init("first note"),
                            .init("second note", "which has second line")
                        )
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .lua),
                        """
                        --- foo.bar.one(a, [b]) -> string, boolean
                        --- Deprecated
                        --- Description that goes
                        --- over two lines.
                        ---
                        --- Parameters:
                        ---  * a - required param
                        ---  * b - optional param
                        ---
                        --- Returns:
                        ---  * a string
                        ---  * `true` if successful
                        ---
                        --- Notes:
                        ---  * first note
                        ---  * second note
                        ---    which has second line
                        """
                    )

                }
                
                it("outputs an objc block") {
                    let value = Doc.function(
                        signature: .init(
                            module: .init("foo", "bar"),
                            name: "one",
                            parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                            returns: ["string", "boolean"]
                        ),
                        deprecated: true,
                        description: .init("Description that goes", "over two lines."),
                        parameters: .init(
                            .init("a - required param"),
                            .init("b - optional param")
                        ),
                        returns: .init(
                            .init("a string"),
                            .init("`true` if successful")
                        ),
                        notes: .init(
                            .init("first note"),
                            .init("second note", "which has second line")
                        )
                    )
                    
                    XCTAssertNoDifference(
                        value.text(for: .objc),
                        """
                        /// foo.bar.one(a, [b]) -> string, boolean
                        /// Deprecated
                        /// Description that goes
                        /// over two lines.
                        ///
                        /// Parameters:
                        ///  * a - required param
                        ///  * b - optional param
                        ///
                        /// Returns:
                        ///  * a string
                        ///  * `true` if successful
                        ///
                        /// Notes:
                        ///  * first note
                        ///  * second note
                        ///    which has second line
                        """
                    )

                }
            }
        }
    }
}
