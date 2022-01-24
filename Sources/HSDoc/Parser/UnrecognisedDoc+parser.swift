import Parsing

extension UnrecognisedDoc {
    /// Collects any sequential `///` or `---` lines. This should only be called after any other ``ModuleDoc``, ``FunctionDoc``, etc parsers have failed, since it will just match all lines with the prefix.
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<Substring, UnrecognisedDoc> {
        Many(atLeast: 1) {
            DocLine {
                Rest().map(String.init)
            }
        }
        .map { UnrecognisedDoc(lines: .init($0)!) }
        .eraseToAnyParser()
    }
}
