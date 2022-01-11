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

@testable import HSDoc

/// Parses the given input to the expected output with the given parser.
func itParses<P,Output>(_ label: String, with parser: P, from input: String, to expected: Output?, leaving remainder: String = "", file: FileString = #file, line: UInt = #line)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    it("\((expected != nil).succeedsOrFails) parsing \(label)") {
        var inputSub = input[...]
        let actual = parser.parse(&inputSub)
        
        if expected == nil {
            expect(file: file, line: line, actual).to(beNil(), description: "to")
        } else {
            expect(file: file, line: line, actual).to(equal(expected), description: "to")
        }
        
        expect(file: file, line: line, inputSub).to(equal(remainder[...]), description: "leaving")
    }
}

/// Parses the given input to the expected output with the given parser.
func itParses<P,Output>(_ label: String, with parser: P, file: FileString = #file, line: UInt = #line, from input: () -> String, to expected: () -> Output?, leaving remainder: () -> String = {""})
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    itParses(label, with: parser, from: input(), to: expected(), leaving: remainder(), file: file, line: line)
}

func itFailsParsing<P,Output>(_ label: String, with parser: P, from input: String, file: FileString = #file, line: UInt = #line)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    itParses(label, with: parser, from: input, to: nil, leaving: input, file: file, line: line)
}

func itFailsParsing<P,Output>(_ label: String, with parser: P, file: FileString = #file, line: UInt = #line, from input: () -> String)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    let input = input()
    itParses(label, with: parser, from: input, to: nil, leaving: input, file: file, line: line)
}

class ParserSpec: QuickSpec {
    override func spec() {
        describe("Parsing") {
            context("docPrefix") {
                given (
                    ("three slashes",       "///",  true,   "",     #line),
                    ("three slashes space", "/// ", true,   "",     #line),
                    ("three dashes",        "---",  true,   "",     #line),
                    ("three dashes space",  "--- ", true,   "",     #line),
                    ("two dashes",          "--",   false,  "--",   #line),
                    ("four slashes",        "////", true,   "/",    #line)
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
            
            context("blankLine") {
                given(
                    ("no spaces",       "///\n",    true,   "",     #line),
                    ("one space",       "/// \n",   true,   "",     #line),
                    ("multiple spaces", "///    \n", true,  "",     #line),
                    ("no newline",      "///",      false,  "///",  #line)
                ) { (label, input, parses, remainder, line: UInt) in
                    
                    it("\(parses.succeedsOrFails) parsing \(label)") {
                        var inputSub = input[...]
                        switch (blankLine.parse(&inputSub), parses) {
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
            
            context("ItemNameSignature") {
                context("any type") {
                    let parser = ItemNameSignature.parser()
                    
                    itParses("single", with: parser) {
                        "foo.bar"
                    } to: {
                        .init(module: .init("foo"), name: "bar", type: .value)
                    }
                    
                    itParses("double", with: parser) {
                        "foo.boo.bar"
                    } to: {
                        .init(module: .init("foo", "boo"), name: "bar", type: .value)
                    }
                    
                    itParses("function", with: parser) {
                        "foo.boo.bar(a)"
                    } to: {
                        .init(module: .init("foo", "boo"), name: "bar", type: .value)
                    } leaving: {
                        "(a)"
                    }
                    
                    itParses("method", with: parser) {
                        "foo.boo:bar(a)"
                    } to: {
                        .init(module: .init("foo", "boo"), name: "bar", type: .method)
                    } leaving: {
                        "(a)"
                    }
                    
                    itFailsParsing("no module", with: parser) {
                        "bar"
                    }
                    
                    itFailsParsing("no module func", with: parser) {
                        "bar(a)"
                    }
                }
                
                context("value type") {
                    let parser = ItemNameSignature.parser(type: .value)
                    
                    itParses("single", with: parser) {
                        "foo.bar"
                    } to: {
                        .init(module: .init("foo"), name: "bar", type: .value)
                    }
                    
                    itParses("double", with: parser) {
                        "foo.boo.bar"
                    } to: {
                        .init(module: .init("foo", "boo"), name: "bar", type: .value)
                    }
                    
                    itParses("function", with: parser) {
                        "foo.boo.bar(a)"
                    } to: {
                        .init(module: .init("foo", "boo"), name: "bar", type: .value)
                    } leaving: {
                        "(a)"
                    }
                    
                    itFailsParsing("method", with: parser) {
                        "foo.boo:bar(a)"
                    }
                    
                    itFailsParsing("no module", with: parser) {
                        "bar"
                    }
                    
                    itFailsParsing("no module func", with: parser) {
                        "bar(a)"
                    }
                }
                
                context("method type") {
                    let parser = ItemNameSignature.parser(type: .method)
                    
                    itFailsParsing("single", with: parser) {
                        "foo.bar"
                    }
                    
                    itFailsParsing("double", with: parser) {
                        "foo.boo.bar"
                    }
                    
                    itFailsParsing("function", with: parser) {
                        "foo.boo.bar(a)"
                    }
                    
                    itParses("method", with: parser) {
                        "foo.boo:bar(a)"
                    } to: {
                        .init(module: .init("foo", "boo"), name: "bar", type: .method)
                    } leaving: {
                        "(a)"
                    }
                    
                    itFailsParsing("no module", with: parser) {
                        "bar"
                    }
                    
                    itFailsParsing("no module func", with: parser) {
                        "bar(a)"
                    }                }
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
                
                itParses("something", with: parser, from: "foo", to: .init("foo"), leaving: "")
                itFailsParsing("nothing", with: parser, from: "")
                itFailsParsing("blank line", with: parser, from: "\n")
                
                context("list") {
                    let parser = ReturnSignature.listParser()
                    
                    itParses("nothing", with: parser, from: "", to: [], leaving: "")
                    
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
                        name: .init(module: .init("foo"), name: "bar", type: .value),
                        parameters: [.init(name: "a"), .init(name: "b")],
                        returns: ["table", "number"]
                    )
                }
                
                itParses("function with optional param", with: parser) {
                    "foo.bar([a])"
                } to: {
                    .init(
                        name: .init(module: .init("foo"), name: "bar", type: .value),
                        parameters: [.init(name: "a", isOptional: true)]
                    )
                }
                
                it("is described correctly with return values") {
                    let value = FunctionSignature(
                        name: .init(module: .init("foo"), name: "bar", type: .value),
                        parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                        returns: ["table", "number"]
                    )
                    
                    expect(value.description).to(equal("foo.bar(a, [b]) -> table, number"))
                }
                
                it("is described correctly with no params or return values") {
                    let value = FunctionSignature(name: .init(module: .init("foo"), name: "bar", type: .value))
                    
                    expect(value.description).to(equal("foo.bar()"))
                }
            }
            
            context("DocLine") {
                it("parses a Lua comment line") {
                    let parser = DocLine(Rest())
                    var input = "--- Foo\n"[...]
                    expect(parser.parse(&input)).to(equal("Foo"))
                    expect(input).to(equal(""[...]))
                }
                
                it("parses a blank Lua comment line") {
                    let parser = DocLine(Rest())
                    var input = "---\n"[...]
                    expect(parser.parse(&input)).to(equal(""))
                    expect(input).to(equal(""[...]))
                }
                
                it("parses a ObjC comment line") {
                    let parser = DocLine(Rest())
                    var input = "/// Foo\n"[...]
                    expect(parser.parse(&input)).to(equal("Foo"))
                    expect(input).to(equal(""[...]))
                }
                
                it("parses when the input ends without a newline") {
                    let parser = DocLine(Rest())
                    var input = "/// Foo"[...]
                    expect(parser.parse(&input)).to(equal("Foo"))
                    expect(input).to(equal(""[...]))
                }
                
                it("passes on leading and trailing whitespace") {
                    let parser = DocLine(Rest())
                    var input = "///   abc  "[...]
                    expect(parser.parse(&input)).to(equal("  abc  "))
                    expect(input).to(equal(""[...]))
                }
            }
            
            context("Doc") {
                let parser = Doc.parser()
                
                itParses("simple function", with: parser) {
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
                } to: {
                    Doc.function(.init(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .value)),
                        description: .init("This is a description."),
                        parameters: .init(ListItem("None")),
                        returns: .init(ListItem("Nothing"))
                    ))
                }
                
                itParses("simple method", with: parser) {
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
                } to: {
                    Doc.method(.init(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .method)),
                        description: .init("This is a description."),
                        parameters: .init(ListItem("None")),
                        returns: .init(ListItem("Nothing"))
                    ))
                }

            }
            
            context("FunctionDoc") {
                let parser = FunctionDoc.parser()
                
                itParses("simple function", with: parser) {
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
                } to: {
                    FunctionDoc(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .value)),
                        description: .init("This is a description."),
                        parameters: .init(ListItem("None")),
                        returns: .init(ListItem("Nothing"))
                    )
                }

                itParses("full function", with: parser) {
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
                } to: {
                    FunctionDoc(
                        signature: .init(name: .init(module: .init("foo", "boo"), name: "bar", type: .value),
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
            
            context("MethodSignature") {
                let parser = MethodSignature.parser()
                
                itParses("function with params and returns", with: parser) {
                    "foo:bar(a, b) -> table, number"
                } to: {
                    .init(
                        name: .init(module: .init("foo"), name: "bar", type: .method),
                        parameters: [.init(name: "a"), .init(name: "b")],
                        returns: ["table", "number"]
                    )
                }
                
                itParses("function with optional param", with: parser) {
                    "foo:bar([a])"
                } to: {
                    .init(
                        name: .init(module: .init("foo"), name: "bar", type: .method),
                        parameters: [.init(name: "a", isOptional: true)]
                    )
                }
                
                it("is described correctly with return values") {
                    let value = MethodSignature(
                        name: .init(module: .init("foo"), name: "bar", type: .method),
                        parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                        returns: ["table", "number"]
                    )
                    
                    expect(value.description).to(equal("foo:bar(a, [b]) -> table, number"))
                }
                
                it("is described correctly with no params or return values") {
                    let value = MethodSignature(
                        name: .init(module: .init("foo"), name: "bar", type: .method)
                    )
                    
                    expect(value.description).to(equal("foo:bar()"))
                }
            }
            
            context("MethodDoc") {
                let parser = MethodDoc.parser()
                
                itParses("simple method", with: parser) {
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
                } to: {
                    MethodDoc(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .method)),
                        description: .init("This is a description."),
                        parameters: .init(ListItem("None")),
                        returns: .init(ListItem("Nothing"))
                    )
                }
                
                itParses("full method", with: parser) {
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
                } to: {
                    MethodDoc(
                        signature: .init(
                            name: .init(module: .init("foo", "boo"), name: "bar", type: .method),
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
            
            context("VariableSignature") {
                let parser = VariableSignature.parser()
                
                itParses("simple", with: parser) {
                    "foo.bar"
                } to: {
                    .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: nil)
                }
                
                itParses("typed", with: parser) {
                    "foo.bar <table>"
                } to: {
                    .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: "<table>")
                }
                
                itParses("trailing space", with: parser) {
                    "foo.bar "
                } to: {
                    .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: nil)
                }

                
                itFailsParsing("function", with: parser) {
                    "foo.bar()"
                }
                
                itFailsParsing("method", with: parser) {
                    "foo:bar()"
                }

            }
            
            context("VariableDoc") {
                let parser = VariableDoc.parser()
                
                itParses("simple", with: parser) {
                    """
                    /// foo.bar
                    /// Variable
                    /// Description.
                    """
                } to: {
                    VariableDoc(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: nil),
                        description: .init("Description.")
                    )
                }
                
                itParses("full", with: parser) {
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
                } to: {
                    VariableDoc(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: "<table: number>"),
                        description: .init("Description."),
                        notes: .init(
                            ListItem("One"),
                            ListItem("Two")
                        )
                    )
                } leaving: {
                    "foo.bar = {}"
                }
                
                itFailsParsing("function signature", with: parser) {
                    """
                    /// foo.bar()
                    /// Variable
                    /// Description.
                    """
                }
                
                itFailsParsing("missing Variable", with: parser) {
                    """
                    /// foo.bar
                    /// Description.
                    """
                }
            }
            
            context("FieldSignature") {
                let parser = FieldSignature.parser()
                
                itParses("simple", with: parser) {
                    "foo.bar"
                } to: {
                    .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: nil)
                }
                
                itParses("typed", with: parser) {
                    "foo.bar <table>"
                } to: {
                    .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: "<table>")
                }
                
                itFailsParsing("function", with: parser) {
                    "foo.bar()"
                }
                
                itFailsParsing("method", with: parser) {
                    "foo:bar()"
                }

            }
            
            context("FieldDoc") {
                let parser = FieldDoc.parser()
                
                itParses("simple", with: parser) {
                    """
                    /// foo.bar
                    /// Field
                    /// Description.
                    """
                } to: {
                    FieldDoc(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: nil),
                        description: .init("Description.")
                    )
                }
                
                itParses("full", with: parser) {
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
                } to: {
                    FieldDoc(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .value), type: "<table: number>"),
                        description: .init("Description."),
                        notes: .init(
                            ListItem("One"),
                            ListItem("Two")
                        )
                    )
                } leaving: {
                    "foo.bar = {}"
                }
                
                itFailsParsing("function signature", with: parser) {
                    """
                    /// foo.bar()
                    /// Field
                    /// Description.
                    """
                }
                
                itFailsParsing("missing Field", with: parser) {
                    """
                    /// foo.bar
                    /// Description.
                    """
                }
            }
            
            context("ModuleDoc") {
                let parser = ModuleDoc.parser()
                
                itParses("module with docs", with: parser) {
                    """
                    --- === foo.bar ===
                    ---
                    --- Description.
                    """
                } to: {
                    .init(
                        name: .init("foo", "bar"),
                        description: .init("Description.")
                    )
                }
            }
        }
    }
}
