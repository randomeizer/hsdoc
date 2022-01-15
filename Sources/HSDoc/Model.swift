//
//  Model.swift
//  
//
//  Created by David Peterson on 31/12/21.
//

import NonEmpty

/// A non-empty list of `String`s.
typealias Lines = NonEmpty<[String]>

// MARK: Identifier

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
    /// The identifier's value.
    var description: String { value }
}

extension Identifier: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        value = stringLiteral
    }
}

// MARK: ModuleName

/// A `Module` describes the path of a Hammerspoon module.
struct ModuleSignature: Hashable {
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

extension ModuleSignature: CustomStringConvertible {
    /// Compact `String` description of the `Module`.
    var description: String {
        path.map { $0.description }.joined(separator: ".")
    }
}

/// A Named argument.
struct ParameterSignature: Equatable {
    /// The name of the argument.
    let name: Identifier
    
    /// If true, the argument is optional.
    let isOptional: Bool
    
    /// Constructs a new `ParameterSignature` with the specified name and optional flag.
    ///
    /// - Parameters:
    ///   - name: The name of the argument.
    ///   - isOptional: If `true`, the argument is optional.
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
    
    /// Constructs a new `ReturnSignature` with the specified value.
    ///
    /// - Parameter value: The return value.
    init(_ value: String) {
        self.value = value
    }
}

extension ReturnSignature: CustomStringConvertible {
    /// Compact `String` description of the `ReturnSignature`.
    var description: String { value }
}

extension ReturnSignature: ExpressibleByStringLiteral {
    /// Allows the `ReturnSignature` to be initialized with a string literal.
    init(stringLiteral: String) {
        self.value = stringLiteral
    }
}

// MARK: Contents

/// Represents a top-level bullet-pointed list item, for lists such as 'Parameters' and 'Returns'.
struct ListItem: Equatable {
    typealias Lines = NonEmpty<[String]>
    
    /// The contents of the list item.
    let lines: Lines
    
    /// Constructs a new `ListItem` with the specified lines.
    ///
    /// - Parameter lines: The lines of the list item.
    init(lines: Lines) {
        self.lines = lines
    }
    
    /// Constructs a new `ListItem` with the specified lines.
    ///
    /// - Parameters:
    ///   - head: The first line.
    ///   - tail: Additional lines.
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

/// Describes the parameters of a function or method.
struct ParametersDoc: Equatable {
    let items: List
    
    /// Constructs a new `ParametersDoc` with the specified list of `ListItem`s.
    ///
    /// - Parameter items: The list of `ListItem`s describing the parameters.
    init(items: List) {
        self.items = items
    }
    
    init(_ head: ListItem, _ tail: ListItem...) {
        var items = List(head)
        items.append(contentsOf: tail)
        self.items = items
    }
}

/// Describes the return values of a function or method.
struct ReturnsDoc: Equatable {

    /// The list of `ListItem`s describing the return values.
    let items: List
    
    /// Constructs a new `ReturnsDoc` with the specified list of `ListItem`s.
    ///
    /// - Parameter items: The list of `ListItem`s describing the return values.
    init(items: List) {
        self.items = items
    }
    
    /// Constructs a new `ReturnsDoc` with the specified list of `ListItem`s.
    ///
    /// - Parameters:
    ///   - head: The first `ListItem`.
    ///   - tail: Additional `ListItem`s.
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

// MARK: Doc

/// Defines the options for documentation segments.
enum Doc: Equatable {
    case module(ModuleDoc)
    case function(FunctionDoc)
    case variable(VariableDoc)
    case method(MethodDoc)
    case field(FieldDoc)
    case unparsed(UnparsedDoc)
}

/// A collection of ``Doc`` values.
typealias Docs = [Doc]

// MARK: Function

/// Defines the signature for a function.
struct FunctionSignature : Equatable {
    /// The optional module for the function.
    let module: ModuleSignature?
    
    /// The name of the function
    let name: Identifier

    /// The parameters of the function.
    let parameters: [ParameterSignature]

    /// The return value(s) of the function.
    let returns: [ReturnSignature]?
    
    /// Constructs a new `FunctionSignature` with the specified name, parameters, and return values.
    ///
    /// - Parameters:
    ///   - module: The optional module of the function.
    ///   - name: The name of the function.
    ///   - parameters: The parameters of the function.
    ///   - returns: The return values of the function.
    init(
        module: ModuleSignature? = nil,
        name: Identifier,
        parameters: [ParameterSignature] = [],
        returns: [ReturnSignature]? = nil
    ) {
        self.module = module
        self.name = name
        self.parameters = parameters
        self.returns = returns
    }
}

extension FunctionSignature: CustomStringConvertible {
    var description: String {
        let moduleDesc = module == nil ? "" : "\(module!)."
        let main = "\(moduleDesc)\(name)(\(parameters.map {String(describing: $0) } .joined(separator: ", ")))"
        guard let returns = returns else {
            return main
        }
        return "\(main) -> \(returns.map { String(describing: $0) } .joined(separator: ", "))"
    }
}

/// Defines the documentation for a function.
struct FunctionDoc: Equatable {
    /// The signature of the function.
    let signature: FunctionSignature

    /// The description of the function.
    let description: DescriptionDoc

    /// The parameters of the function.
    let parameters: ParametersDoc

    /// The return values of the function.
    let returns: ReturnsDoc

    /// The notes for the function.
    let notes: NotesDoc?
    
    /// Constructs a new `FunctionDoc` with the specified signature, description, parameters, return values, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the function.
    ///   - description: The description of the function.
    ///   - parameters: The parameters of the function.
    ///   - returns: The return values of the function.
    ///   - notes: The notes for the function.
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

// MARK: Method

/// Defines the signature for a function.
struct MethodSignature : Equatable {
    let module: ModuleSignature
    let name: Identifier
    let parameters: [ParameterSignature]
    let returns: [ReturnSignature]?
    
    init(
        module: ModuleSignature,
        name: Identifier,
        parameters: [ParameterSignature] = [],
        returns: [ReturnSignature]? = nil
    ) {
        self.module = module
        self.name = name
        self.parameters = parameters
        self.returns = returns
    }
}

extension MethodSignature: CustomStringConvertible {
    var description: String {
        let main = "\(module):\(name)(\(parameters.map {String(describing: $0) } .joined(separator: ", ")))"
        guard let returns = returns else {
            return main
        }
        return "\(main) -> \(returns.map { String(describing: $0) } .joined(separator: ", "))"
    }
}

/// Defines the documentation for a function.
struct MethodDoc: Equatable {
    /// The signature of the method.
    let signature: MethodSignature

    /// The description of the method.
    let description: DescriptionDoc

    /// The parameters of the method.
    let parameters: ParametersDoc

    /// The return values of the method.
    let returns: ReturnsDoc

    /// The notes for the method.
    let notes: NotesDoc?
    
    /// Constructs a new `MethodDoc` with the specified signature, description, parameters, return values, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the method.
    ///   - description: The description of the method.
    ///   - parameters: The parameters of the method.
    ///   - returns: The return values of the method.
    ///   - notes: The notes for the method.
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

/// Defines the signature for a variable.
struct VariableSignature: Equatable {
    /// The optional module name.
    let module: ModuleSignature?
    
    /// The name of the variable.
    let name: Identifier

    /// The optional type of the variable.
    let type: VariableType?
    
    init(module: ModuleSignature? = nil, name: Identifier, type: VariableType? = nil) {
        self.module = module
        self.name = name
        self.type = type
    }
}

extension VariableSignature: CustomStringConvertible {
    /// The variable signature as a string.
    var description: String {
        let moduleDoc = module == nil ? "" : "\(module!)."
        
        if let type = type {
            return "\(moduleDoc)\(name) \(type)"
        } else {
            return "\(moduleDoc)\(name)"
        }
    }
}

/// Defines the documentation for a variable.
struct VariableDoc: Equatable {
    /// The signature of the variable.
    let signature: VariableSignature

    /// The description of the variable.
    let description: DescriptionDoc

    /// The notes for the variable.
    let notes: NotesDoc?
    
    /// Constructs a new `VariableDoc` with the specified signature, description, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the variable.
    ///   - description: The description of the variable.
    ///   - notes: The notes for the variable.
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

/// Defines the signature for a field.
struct FieldSignature: Equatable {
    /// The module name.
    let module: ModuleSignature
    
    /// The name of the field.
    let name: Identifier

    /// The optional type of the field.
    let type: FieldType?
}

extension FieldSignature: CustomStringConvertible {
    /// The field signature as a string.
    var description: String {
        if let type = type {
            return "\(module).\(name) \(type)"
        } else {
            return "\(module).\(name)"
        }
    }
}

/// Defines the documentation for a field.
struct FieldDoc: Equatable {
    /// The signature of the field.
    let signature: FieldSignature

    /// The description of the field.
    let description: DescriptionDoc

    /// The notes for the field.
    let notes: NotesDoc?
    
    /// Constructs a new `FieldDoc` with the specified signature, description, and notes.
    ///
    /// - Parameters:
    ///   - signature: The signature of the field.
    ///   - description: The description of the field.
    ///   - notes: The notes for the field.
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

// MARK: Unparsed

/// Collects any unparsed 'documentation comment' (`///` or `///`) lines to be reported.
/// Note: This should be checked for last, since it will match any block of lines
/// starting with the document comment marker.
struct UnparsedDoc: Equatable {
    let lines: NonEmpty<[String]>
    
    init(lines: NonEmpty<[String]>) {
        self.lines = lines
    }
    
    init(_ head: String, _ tail: String...) {
        var lines = NonEmpty<[String]>(head)
        lines.append(contentsOf: tail)
        self.lines = lines
    }
}

// MARK: Module

/// Defines the documentation for a `Module`.
struct ModuleDoc: Equatable {
    let name: ModuleSignature
    let description: DescriptionDoc
}

/// Defines a module of functions/methods/etc.
class Module {
    let name: ModuleSignature
    
    let doc: ModuleDoc
    
    /// The list of fields defined for the module.
    var fields: [FieldDoc] = []
    
    /// The list of functions defined for the module.
    var functions: [FunctionDoc] = []
    
    /// The list of methods defined for the module.
    var methods: [MethodDoc] = []
    
    /// The list of variables defined for the module.
    var variables: [VariableSignature] = []
    
    /// Constructs a new `Module` with the specified name and documentation.
    ///
    /// - Parameters:
    ///   - doc: The documentation for the module.
    init(doc: ModuleDoc) {
        self.name = doc.name
        self.doc = doc
    }
}
