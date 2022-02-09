import Quick
import Nimble
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
                        description: .init("Description.")
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
                        parameters: .init(ListItem("None")),
                        returns: .init(ListItem("Nothing"))
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
                            ListItem("a - first param", "  with multi-line description."),
                            ListItem("b - optional param.")
                        ),
                        returns: .init(ListItem("a number."), ListItem("a boolean.")),
                        notes: .init(
                            ListItem("a note."),
                            ListItem("another note.")
                        )
                    )
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
                            ListItem("One"),
                            ListItem("Two")
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
                }
                
                itFailsParsing("missing Variable", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar
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
                        parameters: .init(ListItem("None")),
                        returns: .init(ListItem("Nothing"))
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
                            ListItem("a - first param."),
                            ListItem("b - optional param.")
                        ),
                        returns: .init(
                            ListItem("a number."),
                            ListItem("a boolean.")
                        ),
                        notes: .init(
                            ListItem("a note."),
                            ListItem("another note.")
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
                            ListItem("One"),
                            ListItem("Two")
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
                }
                
                itFailsParsing("missing Field", with: parser) {
                    TextDocument {
                    """
                    /// foo.bar
                    /// Description.
                    """
                    }
                }
            }

        }
    }
}
