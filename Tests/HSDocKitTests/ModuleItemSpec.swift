import Foundation
import Nimble
import Quick
@testable import HSDocKit

class ModuleItemSpec: QuickSpec {
    override class func spec() {
        describe("ModuleItem") {
            context("parser") {
                let parser = ModuleItem.parser
            }
            
            context("function") {
                let parser = ModuleItem.functionParser
                
                itParses("simple function") {
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
                } with: {
                    parser
                } to: {
                    ModuleItem.function(
                        signature: .init(module: .init("foo"), name: "bar"),
                        description: .init("This is a description."),
                        parameters: .init(BulletItem("None")),
                        returns: .init(BulletItem("Nothing"))
                    )
                }

                itParses("full function") {
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
                } with: {
                    parser
                } to: {
                    ModuleItem.function(
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
                
                itFailsParsing("missing parameters") {
                    TextDocument {
                    """
                    --- foo.bar(a)
                    --- Function
                    --- Description.
                    """
                    }
                }  with: {
                    parser
                } withErrorMessage: {
                    """
                    error: expected blank line before Parameters
                    """
                } leaving: {
                    TextDocument()
                }
                
                itFailsParsing("missing returns") {
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
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: expected blank line before Returns
                    """
                } leaving: {
                    TextDocument()
                }
                
                
                itFailsParsing("with extra blank line") {
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
                } with: {
                    parser
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
                let parser = ModuleItem.variableParser
                
                itParses("simple") {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Variable
                    /// Description.
                    """
                    }
                } with: {
                    parser
                } to: {
                    ModuleItem.variable(
                        signature: .init(module: .init("foo"), name: "bar", type: nil),
                        description: .init("Description.")
                    )
                }
                
                itParses("full") {
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
                } with: {
                    parser
                } to: {
                    ModuleItem.variable(
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
                
                itFailsParsing("function signature") {
                    TextDocument {
                    """
                    /// foo.bar()
                    /// Variable
                    /// Description.
                    """
                    }
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:12-13
                    1 | /// foo.bar()
                      |            ^^ expected end of input
                    """
                }
                
                itFailsParsing("missing Variable") {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Description.
                    """
                    }
                } with: {
                    parser
                } withErrorMessage: {
                    #warning("low-detail error due to not having access to `Parsing.ParsingError`")
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
                let parser = ModuleItem.methodParser
                
                itParses("simple method") {
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
                } with: {
                    parser
                } to: {
                    ModuleItem.method(
                        signature: .init(module: .init("foo"), name: "bar"),
                        description: .init("This is a description."),
                        parameters: .init(BulletItem("None")),
                        returns: .init(BulletItem("Nothing"))
                    )
                }
                
                itParses("full method") {
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
                } with: {
                    parser
                } to: {
                    ModuleItem.method(
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
                let parser = ModuleItem.fieldParser
                
                itParses("simple") {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Field
                    /// Description.
                    """
                    }
                } with: {
                    parser
                } to: {
                    ModuleItem.field(
                        signature: .init(module: .init("foo"), name: "bar", type: nil),
                        description: .init("Description.")
                    )
                }
                
                itParses("full") {
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
                } with: {
                    parser
                } to: {
                    ModuleItem.field(
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
                
                itFailsParsing("function signature") {
                    TextDocument {
                    """
                    /// foo.bar()
                    /// Field
                    /// Description.
                    """
                    }
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: unexpected input
                     --> input:1:12-13
                    1 | /// foo.bar()
                      |            ^^ expected end of input
                    """
                }
                
                itFailsParsing("missing Field") {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Description.
                    """
                    }
                } with: {
                    parser
                } withErrorMessage: {
                    #warning("low-detail error message due to not having access to `Parsing.ParsingError`")
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
