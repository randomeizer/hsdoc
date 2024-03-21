import Foundation

/// Identifies a module/item/parameter value. Matches the Lua identifier definition:
///
/// "Identifiers in Lua can be any string of letters, digits, and underscores, not beginning with a digit.
/// This coincides with the definition of identifiers in most languages. (The definition of letter depends
/// on the current locale: any character considered alphabetic by the current locale can be used in an identifier.)"
public struct Identifier: Hashable {
    let value: Substring
    
    public init(_ value: Substring) {
        self.value = value
    }
}

extension Identifier: CustomStringConvertible {
    /// The identifier's value.
    public var description: String { String(value) }
}

extension Identifier: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        value = stringLiteral[...]
    }
}
