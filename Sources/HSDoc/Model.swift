//
//  Model.swift
//  
//
//  Created by David Peterson on 31/12/21.
//

import NonEmpty

/// A non-empty list of `String`s.
typealias Lines = NonEmpty<[String]>

/// Identifies a module/item/paramter value. Matches the Lua identifier definition:
///
/// "Identifiers in Lua can be any string of letters, digits, and underscores, not beginning with a digit.
/// This coincides with the definition of identifiers in most languages. (The definition of letter depends
/// on the current locale: any character considered alphabetic by the current locale can be used in an identifier.)"
struct Identifier: Hashable {
    let value: String
    
    init(_ value: String) {
        self.value = value
    }
}

extension Identifier: CustomStringConvertible {
    var description: String { value }
}

extension Identifier: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        value = stringLiteral
    }
}

/// A `Module` describes the path of a Hammerspoon module.
struct ModuleName: Hashable {
    /// The path elements of the module.
    let path: NonEmpty<[Identifier]>
    
    /// Creates a new `Module` with the specified path of `String`s
    /// - Parameter path: The module path.
    init(_ path: NonEmpty<[Identifier]>) {
        self.path = path
    }
    
    /// Creates a new `Module` with the specified steps on the path.
    /// - Parameters:
    ///   - head: The first step
    ///   - tail: Additional steps.
    init(_ head: Identifier, _ tail: Identifier...) {
        var path = NonEmpty<[Identifier]>(head)
        path.append(contentsOf: tail)
        self.path = path
    }
}

extension ModuleName: CustomStringConvertible {
    /// Compact `String` description of the `Module`.
    var description: String {
        path.map { $0.description }.joined(separator: ".")
    }
}

/// Represents an item name, such as a function, method, etc.
struct ItemNameSignature: Equatable {
    
    enum `Type`: Character, Equatable, CustomStringConvertible {
        case value = "."
        case method = ":"
        
        var description: String { String(rawValue) }
    }
    
    /// The `Module`.
    let module: ModuleName
    
    /// The individual item name.
    let name: Identifier
    
    /// If true, it's a method call. If `true`, it uses ":" to connect the module to the item name.
    let type: Type
}

extension ItemNameSignature: CustomStringConvertible {
    var description: String {
        "\(module)\(type)\(name)"
    }
}

extension ItemNameSignature: CustomDebugStringConvertible {
    var debugDescription: String {
        "<\(description)>"
    }
}

/// A Named argument.
struct ParameterSignature: Equatable {
    /// The name of the argument.
    let name: Identifier
    
    /// If true, the argument is optional.
    let isOptional: Bool
    
    init(name: Identifier, isOptional: Bool = false) {
        self.name = name
        self.isOptional = isOptional
    }
}

extension ParameterSignature: CustomStringConvertible {
    var description: String {
        if isOptional {
            return "[\(name)]"
        } else {
            return String(describing: name)
        }
    }
}

/// Represents a single return value for a function or method.
struct ReturnSignature: Equatable {
    let value: String
    
    init(_ value: String) {
        self.value = value
    }
}

extension ReturnSignature: CustomStringConvertible {
    var description: String { value }
}

extension ReturnSignature: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        self.value = stringLiteral
    }
}

/// Defines the signature for a function.
struct FunctionSignature : Equatable {
    let name: ItemNameSignature
    let parameters: [ParameterSignature]
    let returns: [ReturnSignature]?
    
    init(name: ItemNameSignature, parameters: [ParameterSignature] = [], returns: [ReturnSignature]? = nil) {
        self.name = name
        self.parameters = parameters
        self.returns = returns
    }
}

extension FunctionSignature: CustomStringConvertible {
    var description: String {
        let main = "\(name)(\(parameters.map {String(describing: $0) } .joined(separator: ", ")))"
        guard let returns = returns else {
            return main
        }
        return "\(main) -> \(returns.map { String(describing: $0) } .joined(separator: ", "))"
    }
}

/// Represents a top-level bullet-pointed list item, for lists such as 'Parameters' and 'Returns'.
struct ListItem: Equatable {
    typealias Lines = NonEmpty<[String]>
    
    let lines: Lines
    
    init(lines: Lines) {
        self.lines = lines
    }
    
    init(_ head: String, _ tail: String...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.lines = lines
    }
}

typealias List = NonEmpty<[ListItem]>

/// Stores description text for an item.
struct DescriptionDoc: Equatable {
    typealias Lines = NonEmpty<[String]>
    
    let lines: Lines
    
    init(_ lines: Lines) {
        self.lines = lines
    }
    
    init(_ head: String, _ tail: String...) {
        var lines = Lines(head)
        lines.append(contentsOf: tail)
        self.lines = lines
    }
}

struct ParametersDoc: Equatable {
    let items: List
    
    init(items: List) {
        self.items = items
    }
    
    init(_ head: ListItem, _ tail: ListItem...) {
        var items = List(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}

struct ReturnsDoc: Equatable {
    let items: List
    
    init(items: List) {
        self.items = items
    }
    
    init(_ head: ListItem, _ tail: ListItem...) {
        var items = List(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}

/// The list of `Notes` for the item.
struct NotesDoc: Equatable {
    let items: List
    
    init(items: List) {
        self.items = items
    }
    
    init(_ head: ListItem, _ tail: ListItem...) {
        var items = List(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}

/// Defines the documentation for a function.
struct FunctionDoc: Equatable {
    let signature: FunctionSignature
    let description: DescriptionDoc
    let parameters: ParametersDoc
    let returns: ReturnsDoc
    let notes: NotesDoc?
    
    init(
        signature: FunctionSignature,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    ) {
        self.signature = signature
        self.description = description
        self.parameters = parameters
        self.returns = returns
        self.notes = notes
    }
}

/// Defines the signature for a function.
struct MethodSignature : Equatable {
    let name: ItemNameSignature
    let parameters: [ParameterSignature]
    let returns: [ReturnSignature]?
    
    init(name: ItemNameSignature, parameters: [ParameterSignature] = [], returns: [ReturnSignature]? = nil) {
        self.name = name
        self.parameters = parameters
        self.returns = returns
    }
}

extension MethodSignature: CustomStringConvertible {
    var description: String {
        let main = "\(name)(\(parameters.map {String(describing: $0) } .joined(separator: ", ")))"
        guard let returns = returns else {
            return main
        }
        return "\(main) -> \(returns.map { String(describing: $0) } .joined(separator: ", "))"
    }
}

/// Defines the documentation for a function.
struct MethodDoc: Equatable {
    let signature: MethodSignature
    let description: DescriptionDoc
    let parameters: ParametersDoc
    let returns: ReturnsDoc
    let notes: NotesDoc?
    
    init(
        signature: MethodSignature,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    ) {
        self.signature = signature
        self.description = description
        self.parameters = parameters
        self.returns = returns
        self.notes = notes
    }
}

// MARK: Variable

typealias VariableType = String

struct VariableSignature: Equatable {
    let name: ItemNameSignature
    let type: VariableType?
}

extension VariableSignature: CustomStringConvertible {
    var description: String {
        if let type = type {
            return "\(name) \(type)"
        } else {
            return "\(name)"
        }
    }
}

struct VariableDoc: Equatable {
    let signature: VariableSignature
    let description: DescriptionDoc
    let notes: NotesDoc?
    
    init(
        signature: VariableSignature,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    ) {
        self.signature = signature
        self.description = description
        self.notes = notes
    }
}

// MARK: Field

typealias FieldType = String

struct FieldSignature: Equatable {
    let name: ItemNameSignature
    let type: FieldType?
}

extension FieldSignature: CustomStringConvertible {
    var description: String {
        if let type = type {
            return "\(name) \(type)"
        } else {
            return "\(name)"
        }
    }
}

struct FieldDoc: Equatable {
    let signature: FieldSignature
    let description: DescriptionDoc
    let notes: NotesDoc?
    
    init(
        signature: FieldSignature,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    ) {
        self.signature = signature
        self.description = description
        self.notes = notes
    }
}

// MARK: Module

/// Defines the documentation for a `Module`.
struct ModuleDoc: Equatable {
    let name: ModuleName
    let description: DescriptionDoc
}

/// Defines a module of functions/methods/etc.
class Module {
    let name: ModuleName
    
    let doc: ModuleDoc
    
    /// The list of fields defined for the module.
    var fields: [FieldDoc] = []
    
    /// The list of functions defined for the module.
    var functions: [FunctionDoc] = []
    
    /// The list of methods defined for the module.
    var methods: [MethodDoc] = []
    
    /// The list of variables defined for the module.
    var variables: [VariableSignature] = []
    
    init(name: ModuleName, doc: ModuleDoc) {
        self.name = name
        self.doc = doc
    }
}
