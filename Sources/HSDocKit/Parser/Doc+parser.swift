import Parsing
import Dispatch

func deprecable<P>(_ match: P) -> Require<OneOf<Parsers.OneOf2<Parsers.Map<P, Bool>, Parsers.Map<String, Bool>>>>
where P: Parser, P.Input == Substring
{
    Require {
        OneOf {
            match.map { _ in false }
            "Deprecated".map { true }
        }
    } orThrow: { (_, _) in
        LintError.expected("\(match) or Deprecated")
    }
}

extension Doc {
    /// Parses a ``Doc`` from a ``Substring``
    static let parser = OneOf {
        moduleParser
        functionParser
        variableParser
        methodParser
        fieldParser
        unrecognisedParser
    }
    
    static let moduleParser = Parse(Doc.module) {
        DocLine {
            "=== "
            ModuleSignature.nameParser
            " ==="
            Skip { optionalSpaces }
        }
        DocLine { "" }
        DescriptionDoc.parser
    }
    
    static let functionParser = Parse(Doc.function) {
        DocLine(FunctionSignature.parser)
        DocLine(deprecable("Function"))
        DescriptionDoc.parser
        ParametersDoc.parser
        ReturnsDoc.parser
        Optionally { NotesDoc.parser }
    }
    
    static let variableParser = Parse(Doc.variable) {
        DocLine(VariableSignature.parser)
        DocLine(deprecable("Variable"))
        DescriptionDoc.parser
        Optionally { NotesDoc.parser }
    }
    
    static let methodParser = Parse(Doc.method) {
        DocLine(MethodSignature.parser)
        DocLine(deprecable("Method"))
        DescriptionDoc.parser
        ParametersDoc.parser
        ReturnsDoc.parser
        Optionally { NotesDoc.parser }
    }
    
    static let fieldParser = Parse(Doc.field) {
        DocLine(FieldSignature.parser)
        DocLine(deprecable("Field"))
        DescriptionDoc.parser
        Optionally { NotesDoc.parser }
    }
    
    static let unrecognisedParser = OneOrMore {
        DocLine {
            Rest().map(String.init)
        }
    }
    .map(Doc.unrecognised(lines:))
}
