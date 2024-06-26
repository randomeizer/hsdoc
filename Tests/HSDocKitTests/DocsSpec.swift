//
//  DocsParserSpec.swift
//  
//
//  Created by David Peterson on 12/1/22.
//

import Quick
import Nimble
import Parsing

@testable import HSDocKit

class DocsSpec: QuickSpec {
    override class func spec() {
        describe("Docs") {
            context("parser") {
                let parser = Docs.parser
                
                itParses("single function") {
                    TextDocument {
                        """
                        skip this
                        --- my.module.func()
                        --- Function
                        --- Description.
                        ---
                        --- Parameters:
                        ---  * None
                        ---
                        --- Returns:
                        ---  * Nothing
                        """
                    }
                } with: {
                    parser
                } to: {
                    [.init(
                        lineNumber: 2,
                        doc: .item(
                                .function(
                                signature: .init(module: .init("my", "module"), name: "func"),
                                description: .init("Description."),
                                parameters: .init(.init("None")),
                                returns: .init(.init("Nothing")),
                                notes: nil
                            )
                        )
                    )]
                }
                
                itParses("single variable") {
                    TextDocument {
                        """
                        skip this
                        --- my.module.var
                        --- Variable
                        --- Description.
                        """
                    }
                } with: {
                    parser
                } to: {
                    [.init(
                        lineNumber: 2,
                        doc: .item(
                                .variable(
                                signature: .init(module: .init("my", "module"), name: "var"),
                                description: .init("Description.")
                            )
                        )
                    )]
                }
                
                itParses("module and function") {
                    TextDocument {
                        """
                        --- === my.module ===
                        ---
                        --- Module details.
                        
                        local foo = require("foo")
                        
                        local mod = {}
                        
                        --- my.module.funcWithReturn(a, b) -> boolean
                        --- Function
                        --- Function details.
                        ---
                        --- Parameters:
                        ---  * a - a parameter.
                        ---  * b - another parameter.
                        ---
                        --- Returns:
                        ---  * `true` if some condition is met.
                        other code here
                        """
                    }
                } with: {
                    parser
                } to: {
                    [
                        .init(lineNumber: 1, doc: .module(
                            name: .init("my", "module"),
                            details: .init(
                                "Module details."
                            )
                        )),
                        .init(lineNumber: 9, doc: .item(.function(
                            signature: .init(module: .init("my", "module"), name: "funcWithReturn",
                                             parameters: [.init(name: "a"), .init(name: "b")],
                                             returns: [.init("boolean")]),
                            description: .init("Function details."),
                            parameters: .init(.init("a - a parameter."), .init("b - another parameter.")),
                            returns: .init(.init("`true` if some condition is met.")),
                            notes: nil))),
                    ]
                } leaving: {
                    TextDocument(firstLine: 19) {
                        "other code here"
                    }
                }
                
                itParses("clean valid docs") {
                    TextDocument {
                    """
                    --- === my.module ===
                    ---
                    --- Module description.
                    ---
                    --- A second line of description.
                    
                    local foo = require("foo")
                    
                    local mod = {}
                    
                    --- my.module.funcWithReturn(a, b) -> boolean
                    --- Function
                    --- Function description.
                    ---
                    --- Parameters:
                    ---  * a - a parameter.
                    ---  * b - another parameter.
                    ---
                    --- Returns:
                    ---  * `true` if some condition is met.
                    function mod.func(a, b)
                        return true
                    end
                    
                    --- my.module.var
                    --- Variable
                    --- Variable description.
                    mod.var = true
                    
                    --- my.module:methodWithoutReturn(a, [b])
                    --- Method
                    --- Method description.
                    ---
                    --- Parameters:
                    ---  * a - a parameter.
                    ---  * b - an optional parameter.
                    ---
                    --- Returns:
                    ---  * Nothing.
                    function mod:method(a, b)
                    end
                    
                    --- my.module:methodWithReturn(a) -> string
                    --- Method
                    --- Method description.
                    ---
                    --- Parameters:
                    ---  * a - a `string` parameter.
                    ---
                    --- Returns:
                    ---  * The same string.
                    function mod:method(a)
                        return a
                    end
                    
                    --- my.module.field <table: string>
                    --- Field
                    --- A `table` containing `string`s.
                    function mod.lazy.value:field()
                        return {"one", "two", "three"}
                    end
                    """
                    }
                } with: {
                    parser
                } to: {
                    [
                        .init(lineNumber: 1, doc: .module(
                            name: .init("my", "module"),
                            details: .init(
                                "Module description.",
                                "A second line of description."
                            )
                        )),
                        .init(lineNumber: 11, doc: .item(.function(
                            signature: .init(
                                module: .init("my", "module"), name: "funcWithReturn",
                                parameters: [.init(name: "a"), .init(name: "b")],
                                returns: [.init("boolean")]),
                            description: .init("Function description."),
                            parameters: .init(.init("a - a parameter."), .init("b - another parameter.")),
                            returns: .init(.init("`true` if some condition is met.")),
                            notes: nil))),
                        .init(lineNumber: 25, doc: .item(.variable(
                            signature: .init(module: .init("my", "module"), name: "var"),
                            description: .init("Variable description.")))),
                        .init(lineNumber: 30, doc: .item(.method(
                            signature: .init(
                                module: .init("my", "module"), name: "methodWithoutReturn",
                                parameters: [.init(name: "a"), .init(name: "b", isOptional: true)]),
                            description: .init("Method description."),
                            parameters: .init(.init("a - a parameter."), .init("b - an optional parameter.")),
                            returns: .init(.init("Nothing.")),
                            notes: nil))),
                        .init(lineNumber: 43, doc: .item(.method(
                            signature: .init(
                                module: .init("my", "module"), name: "methodWithReturn",
                                parameters: [.init(name: "a")],
                                returns: [.init("string")]
                            ),
                            description: .init("Method description."),
                            parameters: .init(.init("a - a `string` parameter.")),
                            returns: .init(.init("The same string.")),
                            notes: nil))),
                        .init(lineNumber: 56, doc: .item(.field(
                            signature: .init(module: .init("my", "module"), name: "field", type: "<table: string>"),
                            description: .init("A `table` containing `string`s.")
                        )))
                    ]
                } leaving: {
                    TextDocument(firstLine: 59) {
                    """
                    function mod.lazy.value:field()
                        return {"one", "two", "three"}
                    end
                    """
                    }
                }
                
                itParses("global functions and vars") {
                    TextDocument {
                    """
                    local randomCodeHere = true
                    
                    /// globalFunction() -> boolean
                    /// Function
                    /// A global function.
                    ///
                    /// Parameters:
                    ///  * None
                    ///
                    /// Returns:
                    ///  * `true`
                    function globalFunction()
                        return true
                    end
                    
                    /// globalVar <string>
                    /// Variable
                    /// A global variable.
                    globalVar = "Hello, world!"
                    """
                    }
                } with: {
                    parser
                } to: {
                    [
                        .init(lineNumber: 3, doc: .item(.function(
                            signature: .init(name: "globalFunction", returns: ["boolean"]),
                            description: .init("A global function."),
                            parameters: .init(.init("None")),
                            returns: .init(.init("`true`"))
                        ))),
                        .init(lineNumber: 16, doc: .item(.variable(
                            signature: .init(name: "globalVar", type: "<string>"),
                            description: .init("A global variable.")
                        ))),
                    ]
                } leaving: {
                    TextDocument(firstLine: 19) {
                        "globalVar = \"Hello, world!\""
                    }
                }
            }
        }
    }
}
