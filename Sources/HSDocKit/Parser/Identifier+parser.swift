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

func isIdentifierLeadCharacter(_ char: Character) -> Bool {
    char.isLetter || char == "_"
}


extension Identifier {
    /// Parses a `Substring` to an `Identifier`
    static let parser: AnyParser<Substring, Identifier> = Parse(Identifier.init(_:)) {
        Check {
            Prefix(1, while: isIdentifierLeadCharacter(_:))
        } orThrow: { _, _ in
            LintError.expected("letter or underscore")
        }
        Prefix(while: isIdentifier(_:))
    }
    .eraseToAnyParser()
}
