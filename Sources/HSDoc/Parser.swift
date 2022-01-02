//
//  Parser.swift
//  HSDoc
//
//  Created by David Peterson on 31/12/21.
//  Copyright © 2021 Hammerspoon. All rights reserved.
//

import Foundation
import NonEmpty
import Parsing

/// Checks if the provided `Character` is a legal identifier value, according to Lua:
///
/// "Identifiers in Lua can be any string of letters, digits, and underscores, not beginning with a digit.
/// This coincides with the definition of identifiers in most languages. (The definition of letter depends
/// on the current locale: any character considered alphabetic by the current locale can be used in an identifier.)"
///
/// - Parameter value: The character to check
func isIdentifier(_ char: Character) -> Bool {
    char.isLetter || char.isNumber || char == "_"
}

// Parsers for whitespace
let optionalSpace = Prefix(minLength: 0, maxLength: 1, while: { $0 == " " })
let optionalSpaces = Prefix(minLength: 0, while: { $0 == " " })
let oneOrMoreSpaces = Prefix(minLength: 1, while: { $0 == " " })

// Parses a doc-prefixed blank line, terminating with a newline character.
let blankLine = Skip {
    docPrefix
    optionalSpaces
    "\n"
}

let itemPathSeparator: Character = "."
let methodPathSeparator: Character = ":"

let isItemNameValue = isIdentifier

func isModulePathValue(_ value: Character) -> Bool {
    isItemNameValue(value) || value == itemPathSeparator || value == methodPathSeparator
}

extension Identifier {
    /// Parses a `Substring` to an `Identifier`
    /// - Returns: the parser
    static func parser() -> AnyParser<Substring, Identifier> {
        Parse {
            Prefix(1) { $0.isLetter || $0 == "_" }
            Prefix(while: isIdentifier(_:))
        }.map { Identifier("\($0)\($1)") }
        .eraseToAnyParser()
    }
}

// Parsers to convert a "foo.bar" or "foo:bar" `Substring` into a `ModuleItemName`.

// Parses "foo.bar" (non-method) item names.
extension ItemNameSignature {
    /// Creates a `Parser` for the specified type of item name.
    /// - Parameter itemType: The type of item to parse. If `nil`, accepts any type.
    /// - Returns: The `Parser`.
    static func parser(type itemType: ItemNameSignature.`Type`? = nil) -> AnyParser<Substring, ItemNameSignature> {
        switch itemType {
        case .value:
            return Prefix(while: isModulePathValue).pipe(
                Parse {
                    Many(atLeast: 1) {
                        Identifier.parser()
                        "."
                    }
                    Identifier.parser()
                    End()
                }.map { (path, name) -> ItemNameSignature in
                    precondition(!path.isEmpty)
                    let pathStr = NonEmpty<[Identifier]>(path)!
                    return ItemNameSignature(module: .init(pathStr), name: name, type: .value)
                }
            )
            .eraseToAnyParser()
        case .method:
            return Prefix(while: isModulePathValue).pipe(
                Parse {
                    Many {
                        Identifier.parser()
                        "."
                    }
                    Identifier.parser()
                    ":"
                    Identifier.parser()
                    End()
                }
                .map { (ancestors, parent, name) -> ItemNameSignature in
                    var path = ancestors
                    path.append(parent)
                    let pathStr = NonEmpty<[Identifier]>(path)!
                    let module = ModuleName(pathStr)
                    return ItemNameSignature(module: module, name: name, type: .method)
                }
            )
            .eraseToAnyParser()
        case .none:
            return OneOf {
                parser(type: .method)
                parser(type: .value)
            }
            .eraseToAnyParser()
        }
    }
}

// Parses comma separators, allowing for optional spaces either side.
let commaSeparator = Parse {
    Skip(optionalSpaces)
    ","
    Skip(optionalSpaces)
}

// Parses an individual parameter, which may be optional if surrounded by `[]`.
extension ParameterSignature {
    /// Creates a parser to convert a `Substring` into a `ParameterSignature`
    /// - Returns: The parser.
    static func parser() -> AnyParser<Substring, ParameterSignature> {
        OneOf {
            Identifier.parser()
                .map { ParameterSignature(name: $0, isOptional: false) }
            Parse {
                "["
                Identifier.parser()
                "]"
            }.map { ParameterSignature(name: $0, isOptional: true)}
        }
        .eraseToAnyParser()
    }
    
    /// Creates a parser to convert a `Substring` with a bracketted "(list)" of parameter names.
    /// - Returns: The parser.
    static func listParser() -> AnyParser<Substring, [ParameterSignature]> {
        Parse {
            "("
            Skip(optionalSpaces)
            Many {
                ParameterSignature.parser()
            } separatedBy: {
                commaSeparator
            }
            Skip(optionalSpaces)
            ")"
        }
        .eraseToAnyParser()
    }
}

// Parses function/method return values
extension ReturnSignature {
    static func parser() -> AnyParser<Substring, ReturnSignature> {
        Prefix(1...) { !"\r\n,".contains($0) }
        .map { ReturnSignature(String($0.trimmingCharacters(in: .whitespaces))) }
        .eraseToAnyParser()
    }
    
    static func listParser() -> AnyParser<Substring, [ReturnSignature]> {
        Many {
            Self.parser()
        } separatedBy: {
            commaSeparator
        }
        .eraseToAnyParser()
    }
}

extension FunctionSignature {
    static func parser() -> AnyParser<Substring, FunctionSignature> {
        Parse {
            ItemNameSignature.parser(type: .value)
            ParameterSignature.listParser()
            Skip(optionalSpaces)
            OneOf {
                Parse {
                    "->"
                    Skip(optionalSpaces)
                    ReturnSignature.listParser()
                }
                Always([ReturnSignature]())
            }
        }
        .map { FunctionSignature(name: $0, parameters: $1, returns: $2) }
        .eraseToAnyParser()
    }
}

// Parses documentation comment prefixes, including a single optional space.
let docPrefix = Parse {
    OneOf {
        "///" // ObjC
        "---" // Lua
    }
    Skip(optionalSpace)
}

/// Parses a single 'documentation' comment line, starting with `///` or `---` and ending with a newline
/// The `Upstream` `Parser` will only be passed the contents of a single line, excluding the header and the newline.
struct DocLine<Upstream>: Parser where Upstream: Parser, Upstream.Input == Substring {
    let upstream: Upstream
    
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    init(@ParserBuilder upstream: () -> Upstream) {
        self.upstream = upstream()
    }
    
    func parse(_ input: inout Substring) -> Upstream.Output? {
        Parse {
            docPrefix
            Prefix { $0 != "\n" }
            OneOf {
                "\n"
                End()
            }
        }
        .pipe(Parse {
            upstream
            End()
        })
        .parse(&input)
    }
}

// Parses at least one blank documentation line ("///")
let blankDocLines = Skip(Many(atLeast: 1) { DocLine("") })

// Parses at least one description line.
let descriptionBlock = Many(atLeast: 1) {
    DocLine {
        Prefix(1) { !" \n".contains($0) }
        Rest()
    }.map {
        DescriptionDoc("\($0)\($1)")
    }
}

#warning("Does not handle multi-line parameter descriptions.")
let parameterLines = Many(atLeast: 1) {
    DocLine {
        Skip(optionalSpaces)
        "*"
        Rest()
    }.map {
        ParameterDoc("*\($0)")
    }
}

let parametersBlock = Parse {
    blankDocLines
    DocLine("Parameters:")
    parameterLines
}

#warning("Does not handle multi-line return values.")
let returnLines = Many(atLeast: 1) {
    DocLine {
        Skip(optionalSpaces)
        "*"
        Rest()
    }.map {
        ReturnDoc("*\($0)")
    }
}

let returnsBlock = Parse {
    blankDocLines
    DocLine("Returns:")
    returnLines
}

#warning("Does not handle multi-line notes.")
let noteLines = Many(atLeast: 1) {
    DocLine {
        Skip(optionalSpaces)
        "*"
        Rest()
    }.map {
        NoteDoc("*\($0)")
    }
}

let notesBlock = OneOf {
    Parse {
        blankDocLines
        DocLine("Notes:")
        noteLines
    }
    Lazy {Always([NoteDoc]())}
}

extension FunctionDoc {
    static func parser() -> AnyParser<Substring, FunctionDoc> {
        Parse {
            DocLine(FunctionSignature.parser())
            DocLine("Function")
            descriptionBlock
            parametersBlock
            returnsBlock
            notesBlock
        }
        .map { FunctionDoc(
            signature: $0,
            description: $1,
            parameters: $2,
            returns: $3,
            notes: $4
        )}
        .eraseToAnyParser()
    }
}
