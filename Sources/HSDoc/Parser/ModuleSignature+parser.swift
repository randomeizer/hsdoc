import Parsing
import NonEmpty

extension ModuleSignature {
    /// Parses a ``ModuleSignature`` when it is a prefix to another value (eg. a function/method/variable name). It must be followed by either a `'.'` or `':'` character then an identifier.
    /// - Returns: The ``Parser``
    static func prefixParser() -> AnyParser<Substring, ModuleSignature> {
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
            return ModuleSignature(NonEmpty<[Identifier]>(path)!)
        }
        .eraseToAnyParser()
    }
    
    /// Parses a ``ModuleSignature`` when it is not a prefix for another value (eg. `"my.module"` as opposed to `"my.module:method(...)"`.
    /// - Returns: The ``Parser``
    static func nameParser() -> AnyParser<Substring, ModuleSignature> {
        Many(atLeast: 1) {
            Identifier.parser()
        } separator: {
            "."
        }
        .map { path in
            precondition(!path.isEmpty)
            return ModuleSignature(NonEmpty<[Identifier]>(path)!)
        }
        .eraseToAnyParser()
    }
}
