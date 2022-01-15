//
//  DocsParserSpec.swift
//  
//
//  Created by David Peterson on 12/1/22.
//

import Quick
import Nimble
import Parsing

@testable import HSDoc

class DocsParserSpec: QuickSpec {
    override func spec() {
        describe("nonDocLines") {
            itParses("non-doc lines", with: nonDocLines) {
                """
                line 1
                line 2
                --- line 3
                """
            } to: {
                ["line 1", "line 2"]
            } leaving: {
                "--- line 3"
            }
        }
        
        describe("Docs") {
            let parser = Docs.parser()
            
            itParses("single function", with: parser) {
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
            } to: {
                [
                    .function(.init(signature: .init(module: .init("my", "module"), name: "func"),
                                    description: .init("Description."),
                                    parameters: .init(.init("None")),
                                    returns: .init(.init("Nothing")),
                                    notes: nil))
                ]
            }
            
            itParses("single variable", with: parser) {
                """
                skip this
                --- my.module.var
                --- Variable
                --- Description.
                """
            } to: {
                [
                    .variable(.init(
                        signature: .init(module: .init("my", "module"), name: "var"),
                        description: .init("Description.")))
                ]
            }
            
            itParses("module and function", with: parser) {
                """
                --- === my.module ===
                ---
                --- Module description.

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
                other code here
                """
            } to: {
                [
                    .module(.init(name: .init("my", "module"), description: .init("Module description."))),
                    .function(.init(
                        signature: .init(module: .init("my", "module"), name: "funcWithReturn",
                                         parameters: [.init(name: "a"), .init(name: "b")],
                                         returns: [.init("boolean")]),
                        description: .init("Function description."),
                        parameters: .init(.init("a - a parameter."), .init("b - another parameter.")),
                        returns: .init(.init("`true` if some condition is met.")),
                        notes: nil)),
                ]
            }
            
            itParses("clean valid docs", with: parser) {
                """
                --- === my.module ===
                ---
                --- Module description.

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

                --- my.module.badMethod()
                --- Method
                --- Should fail due to missing ':'.
                ---
                --- Parameters:
                ---  * None
                ---
                --- Returns:
                ---  * Nothing
                """
            } to: {
                [
                    .module(.init(name: .init("my", "module"), description: .init("Module description."))),
                    .function(.init(
                        signature: .init(
                            module: .init("my", "module"), name: "funcWithReturn",
                            parameters: [.init(name: "a"), .init(name: "b")],
                            returns: [.init("boolean")]),
                        description: .init("Function description."),
                        parameters: .init(.init("a - a parameter."), .init("b - another parameter.")),
                        returns: .init(.init("`true` if some condition is met.")),
                        notes: nil)),
                    .variable(.init(
                        signature: .init(module: .init("my", "module"), name: "var"),
                        description: .init("Variable description."))),
                    .method(.init(
                        signature: .init(
                            module: .init("my", "module"), name: "methodWithoutReturn",
                            parameters: [.init(name: "a"), .init(name: "b", isOptional: true)]),
                        description: .init("Method description."),
                        parameters: .init(.init("a - a parameter."), .init("b - an optional parameter.")),
                        returns: .init(.init("Nothing.")),
                        notes: nil)),
                    .method(.init(
                        signature: .init(
                            module: .init("my", "module"), name: "methodWithReturn",
                            parameters: [.init(name: "a")],
                            returns: [.init("string")]
                        ),
                        description: .init("Method description."),
                        parameters: .init(.init("a - a `string` parameter.")),
                        returns: .init(.init("The same string.")),
                        notes: nil)),
                    .field(.init(
                        signature: .init(module: .init("my", "module"), name: "field", type: "<table: string>"),
                        description: .init("A `table` containing `string`s.")
                    )),
                    .unparsed(.init(
                        "my.module.badMethod()",
                        "Method",
                        "Should fail due to missing ':'.",
                        "",
                        "Parameters:",
                        " * None",
                        "",
                        "Returns:",
                        " * Nothing"
                    ))
                ]
            }
            
            itParses("global functions and vars", with: parser) {
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
            } to: {
                [
                    .function(.init(
                        signature: .init(name: "globalFunction", returns: ["boolean"]),
                        description: .init("A global function."),
                        parameters: .init(.init("None")),
                        returns: .init(.init("`true`"))
                    )),
                    .variable(.init(
                        signature: .init(name: "globalVar", type: "<string>"),
                        description: .init("A global variable.")
                    )),
                ]
            }

        }
    }
}
