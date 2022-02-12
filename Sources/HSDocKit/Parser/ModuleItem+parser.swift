import Parsing

extension ModuleItem {
    
    static let parser = OneOf {
        constantParser
        constructorParser
        fieldParser
        functionParser
        methodParser
        variableParser
    }
    
    static let constantParser = Parse(Self.constant) {
        DocLine(ConstantSignature.parser)
        DocLine(deprecable("Constant"))
        DescriptionDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    
    static let constructorParser = Parse(Self.constructor) {
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
    
    static let fieldParser = Parse(Self.field) {
        DocLine(FieldSignature.parser)
        DocLine(deprecable("Field"))
        DescriptionDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }
    
    static let functionParser = Parse(Self.function) {
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

    static let methodParser = Parse(Self.method) {
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
    
    static let variableParser = Parse(Self.variable) {
        DocLine(VariableSignature.parser)
        DocLine(deprecable("Variable"))
        DescriptionDoc.parser
        Optionally {
            NotesDoc.parser
        }
    }

}
