//
//  Parser.swift
//  HSDoc
//
//  Created by David Peterson on 31/12/21.
//

import Foundation
import NonEmpty
import Parsing
import ParsingAsync

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

// Parsers for newlines
let optionalNewline = Prefix(minLength: 0, maxLength: 1, while: {$0 == "\n" })
let nonNewlineCharacters = Prefix { $0 != "\n" }

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
        Parse(Identifier.init(_:)) {
            Require(Prefix(1) { $0.isLetter || $0 == "_" })
            Prefix(while: isIdentifier(_:)).map(String.init)
        }
        .eraseToAnyParser()
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
            } separator: {
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
        } separator: {
            commaSeparator
        }
        .eraseToAnyParser()
    }
}

// Parses documentation comment prefixes, including a single optional space.
let docPrefix = Parse {
    OneOf {
        Parse { // ObjC
            "///"
            Not("/")
        }
        Parse { // Lua
            "---"
            Not("-")
        }
    }
    Skip(optionalSpace)
}

/// Parses if the next input is either a `"\n"` or there is no further input.
let endOfLineOrInput = OneOf {
    "\n"
    End()
}

/// Parses a single 'documentation' comment line, starting with `///` or `---` and ending with a newline
/// The `Upstream` ``Parser`` will only be passed the contents of a single line, excluding the header and the newline.
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
            nonNewlineCharacters
            endOfLineOrInput
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
                    Not("*")
                    Rest().map(String.init)
                }
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
            UnparsedDoc.parser().map(Doc.unparsed)
        }
        .eraseToAnyParser()
    }
}

/// Describes a single line, not initiated by a ``docPrefix``, terminated by a `"\n"` or the end of the input.
let nonDocLine = Parse {
    Not(docPrefix)
    nonNewlineCharacters
}

let nonDocLines = Parse {
    Many {
        nonDocLine
    } separator: {
        "\n"
    }
    Skip { optionalNewline }
}

extension Docs {
    static func parser() -> AnyParser<Substring, Docs> {
        Parse {
            Many {
                Skip(nonDocLines)
                Doc.parser()
            }
            Skip(nonDocLines)
        }
        .eraseToAnyParser()
    }
}

// MARK: Function

extension FunctionSignature {
    static func parser() -> AnyParser<Substring, FunctionSignature> {
        Parse(FunctionSignature.init(module:name:parameters:returns:)) {
            Optionally {
                ModuleName.prefixParser()
                "."
            }
            Identifier.parser()
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
            Parse {
                ModuleName.prefixParser()
                ":"
            }
            Identifier.parser()
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
            Optionally {
                ModuleName.prefixParser()
                "."
            }
            Identifier.parser()
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
            ModuleName.prefixParser()
            "."
            Identifier.parser()
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
    static func parser() -> AnyParser<Substring, UnparsedDoc> {
        Many(atLeast: 1) {
            DocLine {
                Rest().map(String.init)
            }
        }
        .map { UnparsedDoc(lines: .init($0)!) }
        .eraseToAnyParser()
    }
}

// MARK: Module

extension ModuleName {
    static func prefixParser() -> AnyParser<Substring, ModuleName> {
        Many(atLeast: 1) {
            Identifier.parser()
            Require {
                OneOf {
                    "."
                    ":"
                }
            }
        } separator: {
            "."
        }
        .map { path in
            precondition(!path.isEmpty)
            return ModuleName(NonEmpty<[Identifier]>(path)!)
        }
        .eraseToAnyParser()
    }
    
    static func nameParser() -> AnyParser<Substring, ModuleName> {
        Many(atLeast: 1) {
            Identifier.parser()
        } separator: {
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
                ModuleName.nameParser()
                " ==="
                Skip(optionalSpaces)
            }
            DocLine("")
            DescriptionDoc.parser()
        }
        .eraseToAnyParser()
    }
}

// MARK: Utility Parsers

/// Parses a `Void` result if the next input does not match the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
struct Not<Upstream>: Parser where Upstream: Parser {
    let upstream: Upstream
    
    /// Construct a ``Not`` with the provided `Upstream` ``Parser``.
    ///
    /// - Parameter upstream: The ``Parser`` to check.
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    /// Construct a ``Not`` with the provided `Upstream` ``ParserBuilder`` closure.
    ///
    /// Parameter build: The `Upstream` ``Parser``-returning closure.
    @inlinable
    init(@ParserBuilder _ build: () -> Upstream) {
      self.upstream = build()
    }
    
    @inlinable
    func parse(_ input: inout Upstream.Input) -> Void? {
      let original = input
      if self.upstream.parse(&input) != nil {
        input = original
        return nil
      }
      return ()
    }
}

/// Parses and returns result if the next input matches the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
struct Peek<Upstream>: Parser where Upstream: Parser {
    let upstream: Upstream
    
    /// Construct a ``Peek`` with the provided `Upstream` ``Parser``.
    ///
    /// - Parameter upstream: The ``Parser`` to check.
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    /// Construct a ``Peek`` with the provided `Upstream` ``ParserBuilder`` closure.
    ///
    /// Parameter build: The `Upstream` ``Parser``-returning closure.
    @inlinable
    init(@ParserBuilder _ build: () -> Upstream) {
      self.upstream = build()
    }
    
    @inlinable
    func parse(_ input: inout Upstream.Input) -> Upstream.Output? {
      let original = input
      if let result = self.upstream.parse(&input) {
        input = original
        return result
      }
      return nil
    }
}

/// Parses a `Void` result if the next input matches the provided `Upstream` ``Parser``,
/// otherwise returns `nil`, in both cases leaving the input unchanged.
struct Require<Upstream>: Parser where Upstream: Parser {
    let upstream: Upstream
    
    /// Construct a ``Peek`` with the provided `Upstream` ``Parser``.
    ///
    /// - Parameter upstream: The ``Parser`` to check.
    @inlinable
    init(_ upstream: Upstream) {
        self.upstream = upstream
    }
    
    /// Construct a ``Peek`` with the provided `Upstream` ``ParserBuilder`` closure.
    ///
    /// Parameter build: The `Upstream` ``Parser``-returning closure.
    @inlinable
    init(@ParserBuilder _ build: () -> Upstream) {
      self.upstream = build()
    }
    
    @inlinable
    func parse(_ input: inout Upstream.Input) -> Void? {
      let original = input
      if self.upstream.parse(&input) != nil {
        input = original
        return ()
      }
      return nil
    }
}

