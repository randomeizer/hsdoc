import Parsing
import Dispatch

func deprecable<P>(_ match: P) -> OneOf<Parsers.OneOf2<Parsers.Map<P, Bool>, Parsers.Map<String, Bool>>>
where P: Parser, P.Input == Substring
{
    OneOf {
        match.map { _ in false }
        "Deprecated".map { true }
    }
}

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
            DocLine(deprecable("Function"))
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
            DocLine(deprecable("Variable"))
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
    
    static func methodParser() -> AnyParser<TextDocument, Doc> {
        Parse(Doc.method) {
            DocLine(MethodSignature.parser())
            DocLine(deprecable("Method"))
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
            DocLine(deprecable("Field"))
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .eraseToAnyParser()
    }
    
    static func unrecognisedParser() -> AnyParser<TextDocument, Doc> {
        OneOrMore {
            DocLine {
                Rest().map(String.init)
            }
        }
        .map(Doc.unrecognised(lines:))
        .eraseToAnyParser()
    }
}
