import Parsing

extension Doc {
    /// Parses a ``Doc`` from a ``Substring``
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, Doc> {
        OneOf {
            ModuleDoc.parser().map(Doc.module)
            FunctionDoc.parser().map(Doc.function)
            VariableDoc.parser().map(Doc.variable)
            MethodDoc.parser().map(Doc.method)
            FieldDoc.parser().map(Doc.field)
            UnrecognisedDoc.parser().map(Doc.unrecognised)
        }
        .eraseToAnyParser()
    }
}
