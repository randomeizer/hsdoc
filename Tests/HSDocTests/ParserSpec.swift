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

let fieldExample = """
/// hs.module.field -> table
/// Field
/// A field in the module.
"""

let methodExample = """
/// hs.module:method(arg1[, arg2]) -> string
/// Method
/// A method in an instance of the module.
///
/// Parameters:
///  * arg1 - a required argument
///  * arg2 - an optional argument
///
/// Returns:
///  * A `string` value.
"""

/// Parses the given input to the expected output with the given parser.
func itParses<P,Output>(_ label: String, with parser: P, from input: String, to expected: Output?, leaving remainder: String, file: FileString = #file, line: UInt = #line)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    it("\((expected != nil).succeedsOrFails) parsing \(label)") {
        var inputSub = input[...]
        let actual = parser.parse(&inputSub)
        
        if expected == nil {
            expect(file: file, line: line, actual).to(beNil())
        } else {
            expect(file: file, line: line, actual).to(equal(expected))
        }
        
        expect(file: file, line: line, inputSub).to(equal(remainder[...]))
    }
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
                    
                    itParses("no module", with: parser, from: "bar",
                             to: nil,
                             leaving: "bar")
                    itParses("single", with: parser, from: "foo.bar",
                             to: .init(module: .init("foo"), name: "bar", type: .value),
                             leaving: "")
                    itParses("double", with: parser, from: "foo.boo.bar",
                             to: .init(module: .init("foo", "boo"), name: "bar", type: .value),
                             leaving: "")
                    itParses("no module func", with: parser, from: "bar(a)",
                             to: nil,
                             leaving: "bar(a)")
                    itParses("function", with: parser, from: "foo.boo.bar(a)",
                             to: .init(module: .init("foo", "boo"), name: "bar", type: .value),
                             leaving: "(a)")
                    itParses("method", with: parser, from: "foo.boo:bar(a)",
                             to: .init(module: .init("foo", "boo"), name: "bar", type: .method),
                             leaving: "(a)")
                }
                
                context("value type") {
                    let parser = ItemNameSignature.parser(type: .value)
                    
                    itParses("no module", with: parser, from: "bar",
                             to: nil,
                             leaving: "bar")
                    itParses("single", with: parser, from: "foo.bar",
                             to: .init(module: .init("foo"), name: "bar", type: .value),
                             leaving: "")
                    itParses("double", with: parser, from: "foo.boo.bar",
                             to: .init(module: .init("foo", "boo"), name: "bar", type: .value),
                             leaving: "")
                    itParses("no module func", with: parser, from: "bar(a)",
                             to: nil,
                             leaving: "bar(a)")
                    itParses("function", with: parser, from: "foo.boo.bar(a)",
                             to: .init(module: .init("foo", "boo"), name: "bar", type: .value),
                             leaving: "(a)")
                    itParses("method", with: parser, from: "foo.boo:bar(a)",
                             to: nil,
                             leaving: "foo.boo:bar(a)")
                }
                
                context("method type") {
                    let parser = ItemNameSignature.parser(type: .method)
                    
                    itParses("no module", with: parser, from: "bar",
                             to: nil,
                             leaving: "bar")
                    itParses("single", with: parser, from: "foo.bar",
                             to: nil,
                             leaving: "foo.bar")
                    itParses("double", with: parser, from: "foo.boo.bar",
                             to: nil,
                             leaving: "foo.boo.bar")
                    itParses("no module func", with: parser, from: "bar(a)",
                             to: nil,
                             leaving: "bar(a)")
                    itParses("function", with: parser, from: "foo.boo.bar(a)",
                             to: nil,
                             leaving: "foo.boo.bar(a)")
                    itParses("method", with: parser, from: "foo.boo:bar(a)",
                             to: .init(module: .init("foo", "boo"), name: "bar", type: .method),
                             leaving: "(a)")
                }
            }
            
            context("ParameterSignature") {
                let parser = ParameterSignature.parser()
                
                itParses("required", with: parser, from: "foo",
                         to: .init(name: "foo", isOptional: false),
                         leaving: "")
                itParses("optional", with: parser, from: "[foo]",
                         to: .init(name: "foo", isOptional: true),
                         leaving: "")
                itParses("unclosed optional", with: parser, from: "[foo",
                         to: nil, leaving: "[foo")
                itParses("unopened optional", with: parser, from: "foo]",
                         to: .init(name: "foo", isOptional: false),
                         leaving: "]")
                itParses("full", with: parser, from: "_foo123",
                         to: .init(name: "_foo123", isOptional: false),
                         leaving: "")
                itParses("number", with: parser, from: "123_foo",
                         to: nil, leaving: "123_foo")
                
                it("is described correctly") {
                    expect(ParameterSignature(name: "foo", isOptional: false).description).to(equal("foo"))
                    expect(ParameterSignature(name: "foo", isOptional: true).description).to(equal("[foo]"))
                }
                
                context("list") {
                    let parser = ParameterSignature.listParser()
                    
                    itParses("empty", with: parser, from: "()", to: [], leaving: "")
                    itParses("one", with: parser, from: "(foo)",
                             to: [.init(name: "foo")],
                             leaving: "")
                    itParses("two", with: parser, from: "(foo, bar)",
                             to: [.init(name: "foo"), .init(name: "bar")],
                             leaving: "")
                    itParses("optional", with: parser, from: "([foo])",
                             to: [.init(name: "foo", isOptional: true)],
                             leaving: "")
                    itParses("mixed", with: parser, from: "(foo, [bar])",
                             to: [.init(name: "foo"), .init(name: "bar", isOptional: true)],
                             leaving: "")
                    itParses("extra comma", with: parser, from: "(foo,)", to: nil, leaving: "(foo,)")
                }
            }
            
            context("ReturnSignature") {
                let parser = ReturnSignature.parser()
                
                itParses("something", with: parser, from: "foo", to: .init("foo"), leaving: "")
                itParses("nothing", with: parser, from: "", to: nil, leaving: "")
                itParses("blank line", with: parser, from: "\n", to: nil, leaving: "\n")
                
                context("list") {
                    let parser = ReturnSignature.listParser()
                    
                    itParses("nothing", with: parser, from: "", to: [], leaving: "")
                    itParses("one", with: parser, from: "foo", to: [.init("foo")], leaving: "")
                    itParses("two", with: parser, from: "foo, bar", to: ["foo", "bar"], leaving: "")
                    itParses("alternate", with: parser, from: "foo, bar | nil", to: ["foo", "bar | nil"], leaving: "")
                    itParses("trimming whitespace", with: parser, from: " foo , bar \t", to: ["foo", "bar"], leaving: "")
                }
            }
            
            context("FunctionSignature") {
                let parser = FunctionSignature.parser()
                
                itParses("function with params and returns", with: parser, from: "foo.bar(a, b) -> table, number",
                         to: .init(name: .init(module: .init("foo"), name: "bar", type: .value), parameters: [.init(name: "a"), .init(name: "b")], returns: ["table", "number"]), leaving: "")
                
                itParses("function with optional param", with: parser, from: "foo.bar([a])",
                         to: .init(name: .init(module: .init("foo"), name: "bar", type: .value), parameters: [.init(name: "a", isOptional: true)]), leaving: "")
                
                it("is described correctly with return values") {
                    let value = FunctionSignature(name: .init(module: .init("foo"), name: "bar", type: .value), parameters: [.init(name: "a"), .init(name: "b", isOptional: true)], returns: ["table", "number"])
                    
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
            
            context("FunctionDoc") {
                let parser = FunctionDoc.parser()
                
                itParses(
                    "simple function", with: parser, from:
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
                        """,
                    to: FunctionDoc(
                        signature: .init(name: .init(module: .init("foo"), name: "bar", type: .value)),
                        description: ["This is a description."],
                        parameters: ["* None"],
                        returns: ["* Nothing"]
                    ),
                    leaving: ""
                )
                
                itParses(
                    "full function", with: parser, from:
                        """
                        --- foo.boo.bar(a, [b]) -> number, boolean
                        --- Function
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
                        """,
                    to: FunctionDoc(
                        signature: .init(name: .init(module: .init("foo", "boo"), name: "bar", type: .value),
                                         parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                                         returns: ["number", "boolean"]),
                        description: ["This is a description","over two lines."],
                        parameters: ["* a - first param.", "* b - optional param."],
                        returns: ["* a number.", "* a boolean."],
                        notes: ["* a note.", "* another note."]
                    ),
                    leaving: ""
                )
            }
        }
    }
}
