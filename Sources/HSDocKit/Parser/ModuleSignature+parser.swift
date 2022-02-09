import Parsing
import NonEmpty

extension ModuleSignature {
    /// Parses a ``ModuleSignature`` when it is a prefix to another value (eg. a function/method/variable name). It must be followed by either a `'.'` or `':'` character then an identifier.
    /// - Returns: The ``Parser``
    static func prefixParser() -> AnyParser<Substring, ModuleSignature> {
        OneOrMore {
            Identifier.parser
            Check {
                OneOf {
                    "."
                    ":"
                }
            }
        } separator: {
            "."
        }
        .map(ModuleSignature.init)
        .eraseToAnyParser()
    }
    
    /// Parses a ``ModuleSignature`` when it is not a prefix for another value (eg. `"my.module"` as opposed to `"my.module:method(...)"`.
    /// - Returns: The ``Parser``
    static func nameParser() -> AnyParser<Substring, ModuleSignature> {
        OneOrMore {
            Identifier.parser
        } separator: {
            "."
        }
        .map(ModuleSignature.init)
        .eraseToAnyParser()
    }
}
