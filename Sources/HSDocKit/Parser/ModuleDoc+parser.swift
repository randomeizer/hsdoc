import Parsing

extension ModuleDoc {
    /// Parses a ``ModuleDoc`` segment from a ``Substring``.
    /// - Returns: The ``Parser``.
    static func parser() -> AnyParser<TextDocument, ModuleDoc> {
        Parse(ModuleDoc.init(name:description:)) {
            DocLine {
                "=== "
                ModuleSignature.nameParser()
                " ==="
                Skip(optionalSpaces)
            }
            DocLine("")
            DescriptionDoc.parser()
        }
        .eraseToAnyParser()
    }
}
