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
                    --- Description.
                    """
                    }
                } to: {
                    Doc.module(
                        name: .init("foo", "bar"),
                        description: .init(.init("Description."))
                    )
                }
            }
            
            context("function") {
                let parser = Doc.functionParser
                
                itParses("simple function", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar()
                    /// Function
                    /// This is a description.
                    ///
                    /// Parameters:
                    ///  * None
                    ///
                    /// Returns:
                    ///  * Nothing
                    """
                    }
                } to: {
                    Doc.function(
                        signature: .init(module: .init("foo"), name: "bar"),
                        description: .init("This is a description."),
                        parameters: .init(BulletItem("None")),
                        returns: .init(BulletItem("Nothing"))
                    )
                }

                itParses("full function", with: parser) {
                    TextDocument {
                    """
                    --- foo.boo.bar(a, [b]) -> number, boolean
                    --- Function
                    --- This is a description
                    --- over two lines.
                    ---
                    --- Parameters:
                    ---  * a - first param
                    ---    with multi-line description.
                    ---  * b - optional param.
                    ---
                    --- Returns:
                    ---  * a number.
                    ---  * a boolean.
                    ---
                    --- Notes:
                    ---  * a note.
                    ---  * another note.
                    """
                    }
                } to: {
                    Doc.function(
                        signature: .init(module: .init("foo", "boo"), name: "bar",
                                         parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                                         returns: ["number", "boolean"]),
                        description: .init(
                            .init("This is a description", "over two lines.")
                        ),
                        parameters: .init(
                            BulletItem("a - first param", "with multi-line description."),
                            BulletItem("b - optional param.")
                        ),
                        returns: .init(BulletItem("a number."), BulletItem("a boolean.")),
                        notes: .init(
                            BulletItem("a note."),
                            BulletItem("another note.")
                        )
                    )
                }
                
                itFailsParsing("missing parameters", with: parser) {
                    TextDocument {
                    """
                    --- foo.bar(a)
                    --- Function
                    --- Description.
                    """
                    }
                } withErrorMessage: {
                    """
                    error: expected blank line before Parameters
                    """
                } leaving: {
                    TextDocument()
                }
                
                itFailsParsing("missing returns", with: parser) {
                    TextDocument {
                    """
                    --- foo.bar(a)
                    --- Function
                    --- Description.
                    ---
                    --- Parameters:
                    ---  * a - The first parameter.
                    """
                    }
                } withErrorMessage: {
                    """
                    error: expected blank line before Returns
                    """
                } leaving: {
                    TextDocument()
                }
                
                
                itFailsParsing("with extra blank line", with: parser) {
                    TextDocument {
                    """
                    --- foo.bar(a)
                    --- Function
                    --- Description.
                    ---
                    ---
                    --- Parameters:
                    ---  * a - The first parameter.
                    """
                    }
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:5:4
                    5 | ---
                      |    ^ expected "Parameters:"
                    """
                } leaving: {
                    TextDocument(firstLine: 5) {
                    """
                    ---
                    --- Parameters:
                    ---  * a - The first parameter.
                    """
                    }
                }
            }
            
            context("variable") {
                let parser = Doc.variableParser
                
                itParses("simple", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Variable
                    /// Description.
                    """
                    }
                } to: {
                    Doc.variable(
                        signature: .init(module: .init("foo"), name: "bar", type: nil),
                        description: .init("Description.")
                    )
                }
                
                itParses("full", with: parser) {
                    TextDocument {
                    """
                    --- foo.bar <table: number>
                    --- Variable
                    --- Description.
                    ---
                    --- Notes:
                    ---  * One
                    ---  * Two
                    foo.bar = {}
                    """
                    }
                } to: {
                    Doc.variable(
                        signature: .init(module: .init("foo"), name: "bar", type: "<table: number>"),
                        description: .init("Description."),
                        notes: .init(
                            BulletItem("One"),
                            BulletItem("Two")
                        )
                    )
                } leaving: {
                    TextDocument(firstLine: 8) {
                    "foo.bar = {}"
                    }
                }
                
                itFailsParsing("function signature", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar()
                    /// Variable
                    /// Description.
                    """
                    }
                } withError: { error in
                    XCTAssertNoDifference("\(error)",  """
                      error: unexpected input
                       --> input:1:12-13
                      1 | /// foo.bar()
                        |            ^^ expected end of input
                      """)
                }
                
                itFailsParsing("missing Variable", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Description.
                    """
                    }
                } withErrorMessage: {
                    #warning("strange error due to not having access to `Parsing.ParsingError`")
                    return "error: expected Variable or Deprecated"
                } leaving: {
                    TextDocument(firstLine: 2) {
                    """
                    /// Description.
                    """
                    }
                }
            }
            
            context("method") {
                let parser = Doc.methodParser
                
                itParses("simple method", with: parser) {
                    TextDocument {
                    """
                    /// foo:bar()
                    /// Method
                    /// This is a description.
                    ///
                    /// Parameters:
                    ///  * None
                    ///
                    /// Returns:
                    ///  * Nothing
                    """
                    }
                } to: {
                    Doc.method(
                        signature: .init(module: .init("foo"), name: "bar"),
                        description: .init("This is a description."),
                        parameters: .init(BulletItem("None")),
                        returns: .init(BulletItem("Nothing"))
                    )
                }
                
                itParses("full method", with: parser) {
                    TextDocument {
                    """
                    --- foo.boo:bar(a, [b]) -> number, boolean
                    --- Method
                    --- This is a description
                    --- over two lines.
                    ---
                    --- Parameters:
                    ---  * a - first param.
                    ---  * b - optional param.
                    ---
                    --- Returns:
                    ---  * a number.
                    ---  * a boolean.
                    ---
                    --- Notes:
                    ---  * a note.
                    ---  * another note.
                    """
                    }
                } to: {
                    Doc.method(
                        signature: .init(
                            module: .init("foo", "boo"), name: "bar",
                            parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                            returns: ["number", "boolean"]
                        ),
                        description: .init("This is a description","over two lines."),
                        parameters: .init(
                            BulletItem("a - first param."),
                            BulletItem("b - optional param.")
                        ),
                        returns: .init(
                            BulletItem("a number."),
                            BulletItem("a boolean.")
                        ),
                        notes: .init(
                            BulletItem("a note."),
                            BulletItem("another note.")
                        )
                    )
                }
            }
            
            context("field") {
                let parser = Doc.fieldParser
                
                itParses("simple", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Field
                    /// Description.
                    """
                    }
                } to: {
                    Doc.field(
                        signature: .init(module: .init("foo"), name: "bar", type: nil),
                        description: .init("Description.")
                    )
                }
                
                itParses("full", with: parser) {
                    TextDocument {
                    """
                    --- foo.bar <table: number>
                    --- Field
                    --- Description.
                    ---
                    --- Notes:
                    ---  * One
                    ---  * Two
                    foo.bar = {}
                    """
                    }
                } to: {
                    Doc.field(
                        signature: .init(module: .init("foo"), name: "bar", type: "<table: number>"),
                        description: .init("Description."),
                        notes: .init(
                            BulletItem("One"),
                            BulletItem("Two")
                        )
                    )
                } leaving: {
                    TextDocument(firstLine: 8) {
                        "foo.bar = {}"
                    }
                }
                
                itFailsParsing("function signature", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar()
                    /// Field
                    /// Description.
                    """
                    }
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:12-13
                    1 | /// foo.bar()
                      |            ^^ expected end of input
                    """
                }
                
                itFailsParsing("missing Field", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Description.
                    """
                    }
                } withErrorMessage: {
                    #warning("strange error message due to not having access to `Parsing.ParsingError`")
                    return "error: expected Field or Deprecated"
                } leaving: {
                    TextDocument(firstLine: 2) {
                    """
                    /// Description.
                    """
                    }
                }
            }

        }
    }
}
