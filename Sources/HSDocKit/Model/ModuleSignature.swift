import NonEmpty

/// A `Module` describes the path of a Hammerspoon module.
public struct ModuleSignature: Hashable {
    /// The path elements of the module.
    public let path: NonEmpty<[Identifier]>
    
    /// Creates a new `Module` with the specified path of `String`s
    /// - Parameter path: The module path.
    public init(_ path: NonEmpty<[Identifier]>) {
        self.path = path
    }
    
    /// Creates a new `Module` with the specified steps on the path.
    /// - Parameters:
    ///   - head: The first step
    ///   - tail: Additional steps.
    public init(_ head: Identifier, _ tail: Identifier...) {
        var path = NonEmpty<[Identifier]>(head)
        path.append(contentsOf: tail)
        self.path = path
    }
}

extension ModuleSignature: CustomStringConvertible {
    /// Compact `String` description of the `Module`.
    public var description: String {
        path.map { $0.description }.joined(separator: ".")
    }
}
