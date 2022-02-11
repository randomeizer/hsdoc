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
    } orThrow: {
        LintError.expected("\(match) or Deprecated")
    }
}

extension Doc {
    /// Parses a ``Doc`` from a ``Substring``
    static let parser = OneOf {
        moduleParser
        functionParser
        constantParser
        variableParser
        constructorParser
        methodParser
        fieldParser
        unrecognisedParser
    }
    
    /// Parses a 'Module'
    static let moduleParser = Parse(Doc.module) {
        DocLine {
            "=== "
            ModuleSignature.nameParser
            " ==="
        }
        OneOrMore {
            blankDocLine
            ParagraphDoc.parser
        }
    }
    
    static let functionParser = Parse(Doc.function) {
        DocLine(FunctionSignature.parser)
        DocLine(deprecable("Function"))
        DescriptionDoc.parser
        ParametersDoc.parser
        ReturnsDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    .verify { value in
        if case let .function(signature, _, _, parameters, _, _) = value,
           case let sigCount = signature.parameters.count,
           case let paramCount = parameters.items.count,
           sigCount == 0 && paramCount != 1,
           sigCount != paramCount
        {
            throw LintError.expected("signature parameter count of \(sigCount) to equal the Parameters count of \(paramCount)")
        }
    }
    
    static let constantParser = Parse(Doc.constant) {
        DocLine(ConstantSignature.parser)
        DocLine(deprecable("Constant"))
        DescriptionDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    
    static let variableParser = Parse(Doc.variable) {
        DocLine(VariableSignature.parser)
        DocLine(deprecable("Variable"))
        DescriptionDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    
    static let constructorParser = Parse(Doc.constructor) {
        DocLine(ConstructorSignature.parser)
        DocLine(deprecable("Constructor"))
        DescriptionDoc.parser
        ParametersDoc.parser
        ReturnsDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    .verify { value in
        if case let .constructor(signature, _, _, parameters, _, _) = value,
           case let sigCount = signature.parameters.count,
           case let paramCount = parameters.items.count,
           sigCount == 0 && paramCount != 1,
           sigCount != paramCount
        {
            throw LintError.expected("signature parameter count of \(sigCount) to equal the Parameters count of \(paramCount)")
        }
    }

    static let methodParser = Parse(Doc.method) {
        DocLine(MethodSignature.parser)
        DocLine(deprecable("Method"))
        DescriptionDoc.parser
        ParametersDoc.parser
        ReturnsDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    .verify { value in
        if case let .method(signature, _, _, parameters, _, _) = value,
           case let sigCount = signature.parameters.count,
           case let paramCount = parameters.items.count,
           sigCount == 0 && paramCount != 1,
           sigCount != paramCount
        {
            throw LintError.expected("signature parameter count of \(sigCount) to equal the Parameters count of \(paramCount)")
        }
    }

    static let fieldParser = Parse(Doc.field) {
        DocLine(FieldSignature.parser)
        DocLine(deprecable("Field"))
        DescriptionDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    
    static let unrecognisedParser = OneOrMore {
        DocLine {
            Rest()
        }
    }
    .map(Doc.unrecognised(lines:))
}
