//
//  Model.swift
//  
//
//  Created by David Peterson on 31/12/21.
//

import NonEmpty

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
        var steps = [head]
        steps.append(contentsOf: tail)
        self.path = .init(steps)!
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
    let returns: [ReturnSignature]
    
    init(name: ItemNameSignature, parameters: [ParameterSignature] = [], returns: [ReturnSignature] = []) {
        self.name = name
        self.parameters = parameters
        self.returns = returns
    }
}

extension FunctionSignature: CustomStringConvertible {
    var description: String {
        let main = "\(name)(\(parameters.map {String(describing: $0) } .joined(separator: ", ")))"
        if returns.isEmpty {
            return main
        }
        return "\(main) -> \(returns.map { String(describing: $0) } .joined(separator: ", "))"
    }
}

#warning("Define types for description/parameter/return/notes/etc.")
typealias DescriptionDoc = String
typealias ParameterDoc = String
typealias ReturnDoc = String
typealias NoteDoc = String

/// Defines the documentation for a function.
struct FunctionDoc: Equatable {
    var signature: FunctionSignature
    var description: [DescriptionDoc]
    var parameters: [ParameterDoc]
    var returns: [ReturnDoc]
    var notes: [NoteDoc]
    
    init(
        signature: FunctionSignature,
        description: [DescriptionDoc],
        parameters: [ParameterDoc],
        returns: [ReturnDoc],
        notes: [NoteDoc] = []
    ) {
        self.signature = signature
        self.description = description
        self.parameters = parameters
        self.returns = returns
        self.notes = notes
    }
    
}
