//
//  Parser.swift
//  HSDoc
//
//  Created by David Peterson on 31/12/21.
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
    
    /// Parses a single return signature value.
    /// - Returns: The parser.
    static func parser() -> AnyParser<Substring, ReturnSignature> {
        Prefix(1...) { !",\n".contains($0) }
        .map { ReturnSignature(String($0.trimmingCharacters(in: .whitespaces))) }
        .eraseToAnyParser()
    }
    
    /// Parses a list of return signature values.
    /// - Returns: The parser.
    static func listParser() -> AnyParser<Substring, [ReturnSignature]> {
        Many {
            Self.parser()
        } separatedBy: {
            commaSeparator
        }
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
/// It must consume the whole contents of the line, other than trailing whitespace.
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
            Skip(optionalSpaces)
            End()
        })
        .parse(&input)
    }
}

// Parses at least one blank documentation line ("///")
let blankDocLines = Skip(Many(atLeast: 1) { DocLine("") })

extension DescriptionDoc {
    static func parser() -> AnyParser<Substring, DescriptionDoc> {
        Many(atLeast: 1) {
            DocLine {
                optionalSpaces
                Prefix(1...)
            }
            .map { "\($0)\($1)" }
        }
        .map { DescriptionDoc(.init($0)!) }
        .eraseToAnyParser()
    }
}

extension ListItem {
    /// Creates a `Parser` for list items.
    /// - Returns: The `Parser`.
    static func parser() -> Parsers.ListItemParser {
        .init()
    }
}

extension List {
    static func parser() -> AnyParser<Substring, List> {
        Many(atLeast: 1) {
            ListItem.parser()
        }
        .map {
            precondition(!$0.isEmpty)
            return List($0)!
        }
        .eraseToAnyParser()
    }
}

extension Parsers {
    /// Parses a 'list item' line, along with any following lines which are sub-elements of the item, due to indentation.
    struct ListItemParser: Parser
    {
        func parse(_ input: inout Substring) -> ListItem? {
            var inputCopy = input
            let listItemFirstLine = DocLine {
                optionalSpaces
                "* "
                Rest()
            }

            guard let (inset, body) = listItemFirstLine.parse(&inputCopy) else {
                return nil
            }
            
            let subLineParser = Many {
                DocLine {
                    Skip(String(inset))
                    Prefix(1) { $0 != "*" }
                    Rest()
                }
                .map { "\($0)\($1)" }
            }
            guard let subLines = subLineParser.parse(&inputCopy) else {
                return nil
            }
            
            var lines = ListItem.Lines(String(body))
            lines.append(contentsOf: subLines)
            
            input = inputCopy
            return ListItem(lines: lines)
        }
    }
}

extension ParametersDoc {
    static func parser() -> AnyParser<Substring, ParametersDoc> {
        Parse(ParametersDoc.init(items:)) {
            blankDocLines
            DocLine("Parameters:")
            List.parser()
        }
        .eraseToAnyParser()
    }
}

extension ReturnsDoc {
    static func parser() -> AnyParser<Substring, ReturnsDoc> {
        Parse(ReturnsDoc.init(items:)) {
            blankDocLines
            DocLine("Returns:")
            List.parser()
        }
        .eraseToAnyParser()
    }
}

extension NotesDoc {
    static func parser() -> AnyParser<Substring, NotesDoc> {
        Parse(NotesDoc.init(items:)) {
            blankDocLines
            DocLine("Notes:")
            List.parser()
        }
        .eraseToAnyParser()
    }
}

// MARK: Doc

extension Doc {
    static func parser() -> AnyParser<Substring, Doc> {
        OneOf {
            ModuleDoc.parser().map(Doc.module)
            FunctionDoc.parser().map(Doc.function)
            VariableDoc.parser().map(Doc.variable)
            MethodDoc.parser().map(Doc.method)
            FieldDoc.parser().map(Doc.field)
        }
        .eraseToAnyParser()
    }
}

// MARK: Function

extension FunctionSignature {
    static func parser() -> AnyParser<Substring, FunctionSignature> {
        Parse(FunctionSignature.init(name:parameters:returns:)) {
            ItemNameSignature.parser(type: .value)
            ParameterSignature.listParser()
            Skip(optionalSpaces)
            Optionally {
                "->"
                Skip(optionalSpaces)
                ReturnSignature.listParser()
            }
            End()
        }
        .eraseToAnyParser()
    }
}

extension FunctionDoc {
    static func parser() -> AnyParser<Substring, FunctionDoc> {
        Parse(FunctionDoc.init) {
            DocLine(FunctionSignature.parser())
            DocLine("Function")
            DescriptionDoc.parser()
            ParametersDoc.parser()
            ReturnsDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}

// MARK: Method

extension MethodSignature {
    static func parser() -> AnyParser<Substring, MethodSignature> {
        Parse(MethodSignature.init) {
            ItemNameSignature.parser(type: .method)
            ParameterSignature.listParser()
            Skip(optionalSpaces)
            Optionally {
                "->"
                Skip(optionalSpaces)
                ReturnSignature.listParser()
            }
            End()
        }
        .eraseToAnyParser()
    }
}

extension MethodDoc {
    static func parser() -> AnyParser<Substring, MethodDoc> {
        Parse(MethodDoc.init) {
            DocLine(MethodSignature.parser())
            DocLine("Method")
            DescriptionDoc.parser()
            ParametersDoc.parser()
            ReturnsDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}

// MARK: Variable

extension VariableSignature {
    static func parser() -> AnyParser<Substring, VariableSignature> {
        Parse(VariableSignature.init) {
            ItemNameSignature.parser(type: .value)
            Optionally {
                Skip(oneOrMoreSpaces)
                Prefix(1...).map(VariableType.init)
            }
            Skip(optionalSpaces)
            End()
        }
        .eraseToAnyParser()
    }
}

extension VariableDoc {
    static func parser() -> AnyParser<Substring, VariableDoc> {
        Parse(VariableDoc.init) {
            DocLine(VariableSignature.parser())
            DocLine("Variable")
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}

// MARK: Field

extension FieldSignature {
    static func parser() -> AnyParser<Substring, FieldSignature> {
        Parse(FieldSignature.init) {
            ItemNameSignature.parser(type: .value)
            Optionally {
                Skip(oneOrMoreSpaces)
                Rest().map(FieldType.init)
            }
            End()
        }
        .eraseToAnyParser()
    }
}

extension FieldDoc {
    static func parser() -> AnyParser<Substring, FieldDoc> {
        Parse(FieldDoc.init) {
            DocLine(FieldSignature.parser())
            DocLine("Field")
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
}

// MARK: UnparsedDoc {
extension UnparsedDoc {
    static func parse() -> AnyParser<Substring, UnparsedDoc> {
        Many(atLeast: 1) {
            DocLine {
                Prefix(1) { $0 != "/" }
                Rest()
            }
            .map { "\($0)\($1)" }
        }
        .map { UnparsedDoc(lines: .init($0)!) }
        .eraseToAnyParser()
    }
}

// MARK: Module

extension ModuleName {
    static func parser() -> AnyParser<Substring, ModuleName> {
        Many(atLeast: 1) {
            Identifier.parser()
        } separatedBy: {
            "."
        }
        .map { path in
            precondition(!path.isEmpty)
            return ModuleName(NonEmpty<[Identifier]>(path)!)
        }
        .eraseToAnyParser()
    }
}

extension ModuleDoc {
    static func parser() -> AnyParser<Substring, ModuleDoc> {
        Parse(ModuleDoc.init(name:description:)) {
            DocLine {
                "=== "
                ModuleName.parser()
                " ==="
                Skip(optionalSpaces)
            }
            DocLine("")
            DescriptionDoc.parser()
        }
        .eraseToAnyParser()
    }
}
