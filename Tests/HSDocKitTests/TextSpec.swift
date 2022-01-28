import Quick
import Nimble
import CustomDump

@testable import HSDocKit

class TextSpec: QuickSpec {
    override func spec() {
        describe("text") {
            context("ListItem") {
                it("outputs a single line") {
                    let value = ListItem("one")
                    
                    expect(value.text(for: .lua)).to(equal(
                        "one"
                    ))
                }
                
                it("outputs multiple lines") {
                    let value = ListItem(
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
                    let value = List(
                        ListItem("one")
                    )
                    
                    expect(value.text(for: .lua)).to(equal(
                        """
                        ---  * one
                        """
                    ))
                }
                
                it("outputs a single multiline item") {
                    let value = List(
                        ListItem("one", "two", "three")
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
                    let value = List(
                        ListItem("one"),
                        ListItem("two"),
                        ListItem("three")
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
                    let value = List(
                        ListItem("alpha", "beta"),
                        ListItem("one", "two"),
                        ListItem("three")
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
                        "one", "two"
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
                        ListItem("one")
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
                        ListItem("one"),
                        ListItem("two")
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
                        ListItem("one")
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
                        ListItem("one"),
                        ListItem("two")
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
                        ListItem("one")
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
                        ListItem("one"),
                        ListItem("two")
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
