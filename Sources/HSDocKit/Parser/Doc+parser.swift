import Parsing

extension Doc {
    /// Parses a ``Doc`` from a ``Substring``
    /// - Returns: The ``Parser``
    static func parser() -> AnyParser<TextDocument, Doc> {
        OneOf {
            moduleParser()
            functionParser()
            variableParser()
            methodParser()
            fieldParser()
            unrecognisedParser()
        }
        .eraseToAnyParser()
    }
    
    static func moduleParser() -> AnyParser<TextDocument, Doc> {
        Parse(Doc.module) {
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
    
    static func functionParser() -> AnyParser<TextDocument, Doc> {
        Parse(Doc.function) {
            DocLine(FunctionSignature.parser())
            DocLine("Function")
            DescriptionDoc.parser()
            ParametersDoc.parser()
            ReturnsDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
    
    static func variableParser() -> AnyParser<TextDocument, Doc> {
        Parse(Doc.variable) {
            DocLine(VariableSignature.parser())
            DocLine("Variable")
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
    
    static func methodParser() -> AnyParser<TextDocument, Doc> {
        Parse(Doc.method) {
            DocLine(MethodSignature.parser())
            DocLine("Method")
            DescriptionDoc.parser()
            ParametersDoc.parser()
            ReturnsDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
    
    static func fieldParser() -> AnyParser<TextDocument, Doc> {
        Parse(Doc.field) {
            DocLine(FieldSignature.parser())
            DocLine("Field")
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
    
    static func unrecognisedParser() -> AnyParser<TextDocument, Doc> {
        Many(atLeast: 1) {
            DocLine {
                Rest().map(String.init)
            }
        }
        .map { Doc.unrecognised(lines: .init($0)!) }
        .eraseToAnyParser()
    }
}
