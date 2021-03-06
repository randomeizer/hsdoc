//
//  ParserSpec.swift
//  
//
//  Created by David Peterson on 31/12/21.
//

import Quick
import Nimble
import NonEmpty
import Parsing

@testable import HSDocKit

class ParserSpec: QuickSpec {
    override func spec() {
        describe("Parsing") {
            context("Identifier") {
                let parser = Identifier.parser()
                
                itParses("alphas", with: parser) {
                    "foo"
                } to: {
                    .init("foo")
                }
                
                itParses("underscore", with: parser) {
                    "_foo"
                } to: {
                    .init("_foo")
                }
                
                itParses("alphanumeric", with: parser) {
                    "abc123"
                } to: {
                    .init("abc123")
                }
                
                itFailsParsing("numericalpha", with: parser, from: "123abc")

            }
            
            context("docPrefix") {
                given (
                    ("three slashes",       "///",  true,   "",     #line),
                    ("three slashes space", "/// ", true,   "",     #line),
                    ("three dashes",        "---",  true,   "",     #line),
                    ("three dashes space",  "--- ", true,   "",     #line),
                    ("two dashes",          "--",   false,  "--",   #line),
                    ("four dashes",         "----", false,  "----", #line),
                    ("two slashes",         "//",   false,  "//",   #line),
                    ("four slashes",        "////", false,  "////", #line),
                    ("slash dash",          "///-", true,   "-",    #line),
                    ("dash slash",          "---/", true,   "/",    #line)
                ) { (label, input, parses, remainder, line: UInt) in
                    
                    it("\(parses.succeedsOrFails) parsing \(label)") {
                        var inputSub = input[...]
                        switch (docPrefix.parse(&inputSub), parses) {
                        case (.none, true):
                            fail("expected to parse <\"\(input)\">", line: line)
                        case (.some, false):
                            fail("expected not to parse <\"\(input)\">", line: line)
                        default:
                            break
                        }
                        
                        expect(line: line, inputSub).to(equal(remainder[...]))
                    }
                }
            }
            
            context("ParameterSignature") {
                let parser = ParameterSignature.parser()
                
                itParses("required", with: parser) {
                    "foo"
                } to: {
                    .init(name: "foo", isOptional: false)
                }
                
                itParses("optional", with: parser) {
                    "[foo]"
                } to: {
                    .init(name: "foo", isOptional: true)
                }
                
                itFailsParsing("unclosed optional", with: parser) { "[foo" }
                
                itParses("unopened optional", with: parser) {
                    "foo]"
                } to: {
                    .init(name: "foo", isOptional: false)
                } leaving: {
                    "]"
                }
                
                itParses("full", with: parser) {
                    "_foo123"
                } to: {
                    .init(name: "_foo123", isOptional: false)
                }
                
                itFailsParsing("number", with: parser) { "123_foo" }
                
                it("is described correctly") {
                    expect(ParameterSignature(name: "foo", isOptional: false).description).to(equal("foo"))
                    expect(ParameterSignature(name: "foo", isOptional: true).description).to(equal("[foo]"))
                }
                
                context("list") {
                    let parser = ParameterSignature.listParser()
                    
                    itParses("empty", with: parser, from: "()", to: [], leaving: "")
                    
                    itParses("one", with: parser) {
                        "(foo)"
                    } to: {
                        [.init(name: "foo")]
                    }
                    
                    itParses("two", with: parser) {
                        "(foo, bar)"
                    } to: {
                        [.init(name: "foo"), .init(name: "bar")]
                    }
                    
                    itParses("optional", with: parser) {
                        "([foo])"
                    } to: {
                        [.init(name: "foo", isOptional: true)]
                    }
                    
                    itParses("mixed", with: parser) {
                        "(foo, [bar])"
                    } to: {
                        [.init(name: "foo"), .init(name: "bar", isOptional: true)]
                    }
                    
                    itFailsParsing("extra comma", with: parser) {
                        "(foo,)"
                    }
                }
            }
            
            context("ReturnSignature") {
                let parser = ReturnSignature.parser()
                
                itParses("something", with: parser, from: "foo", to: .init("foo"))
                itFailsParsing("nothing", with: parser, from: "")
                itFailsParsing("blank line", with: parser, from: "\n")
                
                context("list") {
                    let parser = ReturnSignature.listParser()
                    
                    itParses("nothing", with: parser, from: "", to: [])
                    
                    itParses("one", with: parser) {
                        "foo"
                    } to: {
                        [ReturnSignature("foo")]
                    }
                    
                    itParses("two", with: parser) {
                        "foo, bar"
                    } to: {
                        ["foo", "bar"]
                    }
                    
                    itParses("alternate", with: parser) {
                        "foo, bar | nil"
                    } to: {
                        ["foo", "bar | nil"]
                    }
                    
                    itParses("trimming whitespace", with: parser) {
                        " foo , bar \t"
                    } to: {
                        ["foo", "bar"]
                    }
                }
            }
            
            context("FunctionSignature") {
                let parser = FunctionSignature.parser()
                
                itParses("function with params and returns", with: parser) {
                    "foo.bar(a, b) -> table, number"
                } to: {
                    FunctionSignature(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a"), .init(name: "b")],
                        returns: ["table", "number"]
                    )
                }
                
                itParses("function with optional param", with: parser) {
                    "foo.bar([a])"
                } to: {
                    .init(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a", isOptional: true)]
                    )
                }
                
                it("is described correctly with return values") {
                    let value = FunctionSignature(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                        returns: ["table", "number"]
                    )
                    
                    expect(value.description).to(equal("foo.bar(a, [b]) -> table, number"))
                }
                
                it("is described correctly with no params or return values") {
                    let value = FunctionSignature(module: .init("foo"), name: "bar")
                    
                    expect(value.description).to(equal("foo.bar()"))
                }
            }
            
            context("DocLine") {
                it("parses a Lua comment line") {
                    let parser = DocLine(Rest())
                    var input = TextDocument { "--- Foo" }
                    expect(parser.parse(&input)).to(equal("Foo"))
                    expect(input).to(haveCount(0))
                }
                
                it("parses a blank Lua comment line") {
                    let parser = DocLine(Rest())
                    var input = TextDocument { "---\n"  }
                    expect(parser.parse(&input)).to(equal(""))
                    expect(input).to(equal(TextDocument(firstLine: 2) { "" }))
                }
                
                it("parses a ObjC comment line") {
                    let parser = DocLine(Rest())
                    var input = TextDocument { "/// Foo\n" }
                    expect(parser.parse(&input)).to(equal("Foo"))
                    expect(input).to(equal(TextDocument(firstLine: 2) { "" } ))
                }
                
                it("parses when the input ends without a newline") {
                    let parser = DocLine(Rest())
                    var input = TextDocument { "/// Foo" }
                    expect(parser.parse(&input)).to(equal("Foo"))
                    expect(input).to(equal(TextDocument()))
                }
                
                it("passes on leading and trailing whitespace") {
                    let parser = DocLine(Rest())
                    var input = TextDocument { "///   abc  " }
                    expect(parser.parse(&input)).to(equal("  abc  "))
                    expect(input).to(equal(TextDocument()))
                }
            }
            
            context("Doc") {
                
                context("module") {
                    let parser = Doc.moduleParser()
                    
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
                    let parser = Doc.functionParser()
                    
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
                            description: .init("This is a description","over two lines."),
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
                    let parser = Doc.variableParser()
                    
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
                    let parser = Doc.methodParser()
                    
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
                    let parser = Doc.fieldParser()
                    
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
            
            context("MethodSignature") {
                let parser = MethodSignature.parser()
                
                itParses("function with params and returns", with: parser) {
                    "foo:bar(a, b) -> table, number"
                } to: {
                    .init(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a"), .init(name: "b")],
                        returns: ["table", "number"]
                    )
                }
                
                itParses("function with optional param", with: parser) {
                    "foo:bar([a])"
                } to: {
                    .init(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a", isOptional: true)]
                    )
                }
                
                it("is described correctly with return values") {
                    let value = MethodSignature(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                        returns: ["table", "number"]
                    )
                    
                    expect(value.description).to(equal("foo:bar(a, [b]) -> table, number"))
                }
                
                it("is described correctly with no params or return values") {
                    let value = MethodSignature(
                        module: .init("foo"), name: "bar"
                    )
                    
                    expect(value.description).to(equal("foo:bar()"))
                }
            }
            
            context("VariableSignature") {
                let parser = VariableSignature.parser()
                
                itParses("simple", with: parser) {
                    "foo.bar"
                } to: {
                    .init(module: .init("foo"), name: "bar", type: nil)
                }
                
                itParses("typed", with: parser) {
                    "foo.bar <table>"
                } to: {
                    .init(module: .init("foo"), name: "bar", type: "<table>")
                }
                
                itParses("trailing space", with: parser) {
                    "foo.bar "
                } to: {
                    .init(module: .init("foo"), name: "bar", type: nil)
                }

                
                itFailsParsing("function", with: parser) {
                    "foo.bar()"
                }
                
                itFailsParsing("method", with: parser) {
                    "foo:bar()"
                }

            }
            
            context("FieldSignature") {
                let parser = FieldSignature.parser()
                
                itParses("simple", with: parser) {
                    "foo.bar"
                } to: {
                    .init(module: .init("foo"), name: "bar", type: nil)
                }
                
                itParses("typed", with: parser) {
                    "foo.bar <table>"
                } to: {
                    .init(module: .init("foo"), name: "bar", type: "<table>")
                }
                
                itFailsParsing("function", with: parser) {
                    "foo.bar()"
                }
                
                itFailsParsing("method", with: parser) {
                    "foo:bar()"
                }

            }
            
            context("Not") {
                let uncommentedLine = Parse {
                    Not { "//" }
                    Prefix { $0 != "\n" }
                }
                
                itParses("uncommented line", with: uncommentedLine) {
                    "not a comment"
                } to: {
                    "not a comment"
                }
                
                itFailsParsing("commented line", with: uncommentedLine, from: "// comment")
                
                context("Many") {
                    let commentedLine = Parse {
                        "//"
                        Prefix { $0 != "\n" }
                    }
                    let parser = Many {
                        OneOf {
                            commentedLine
                            uncommentedLine
                        }
                    } separator: {
                        "\n"
                    }
                    
                    itParses("lines", with: parser) {
                        """
                        uncommented
                        // commented
                        also uncommented
                        """
                    } to: {
                        ["uncommented", " commented", "also uncommented"]
                    }
                }
            }
        }
    }
}
