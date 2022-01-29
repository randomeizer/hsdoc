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
    
    static func functionParser() -> Parsers.FunctionParser {
        Parsers.FunctionParser()
    }
    
    static func variableParser() -> AnyParser<TextDocument, Doc> {
        Parse {
            DocLine(VariableSignature.parser())
            DocLine(deprecable("Variable"))
            DescriptionDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .map { (signature, deprecated, description, notesResult) in
            let notes: NotesDoc?
            switch notesResult {
            case .none:
                notes = nil
            case .success(let result):
                notes = result
            case .failure(let err):
                return .error(err)
            }
            
            return Doc.variable(
                signature: signature,
                deprecated: deprecated,
                description: description,
                notes: notes
            )
        }
        .eraseToAnyParser()
    }
    
    static func methodParser() -> AnyParser<TextDocument, Doc> {
        Parse {
            DocLine(MethodSignature.parser())
            DocLine(deprecable("Method"))
            DescriptionDoc.parser()
            ParametersDoc.parser()
            ReturnsDoc.parser()
            Optionally { NotesDoc.parser() }
        }
        .map { (signature, deprecated, description, paramsResult, returnsResult, notesResult) in
            let parameters: ParametersDoc!
            switch paramsResult {
            case .success(let result):
                parameters = result
            case .failure(let err):
                return .error(err)
            }

            let returns: ReturnsDoc!
            switch returnsResult {
            case .success(let result):
                returns = result
            case .failure(let err):
                return .error(err)
            }
            
            let notes: NotesDoc?
            switch notesResult {
            case .none:
                notes = nil
            case .success(let result):
                notes = result
            case .failure(let err):
                return .error(err)
            }

            return Doc.method(
                signature: signature,
                deprecated: deprecated,
                description: description,
                parameters: parameters,
                returns: returns,
                notes: notes
            )
        }
        .eraseToAnyParser()
    }
    
    static func fieldParser2() -> AnyParser<TextDocument, Result<Doc, ParseError>>
    {
        Try {
            DocLine(FieldSignature.parser())
            DocLine(deprecable("Field"))
            Require {
                DescriptionDoc.parser()
            } or: {
                ParseError.expected("field to have a description")
            }
            NotesDoc.parser()
        }
        .mapSuccess(Doc.field(signature:deprecated:description:notes:))
        .eraseToAnyParser()
    }
    
    static func fieldParser() -> AnyParser<TextDocument, Doc> {
        Parse {
            DocLine(FieldSignature.parser())
            DocLine(deprecable("Field"))
            DescriptionDoc.parser()
            NotesDoc.parser()
        }
        .map { (signature, deprecated, description, notesResult) in
            let notes: NotesDoc?
            switch notesResult {
            case .success(let result):
                notes = result
            case .failure(let err):
                return .error(err)
            }
            
            return Doc.field(
                signature: signature,
                deprecated: deprecated,
                description: description,
                notes: notes
            )
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

#warning("Delete once testing is complete.")
extension Doc {
    static func field(signature: FieldSignature, deprecated: Bool, description: DescriptionDoc) -> Doc {
        Doc.field(signature: signature, deprecated: deprecated, description: description, notes: nil)
    }
}

fileprivate let allDocLines = Many {
    DocLine {
        Rest().map(String.init)
    }
}

extension Doc {
    static func error(expected message: String, actual input: inout TextDocument) -> Doc {
        let line = input.first?.number
        let actual = allDocLines.parse(&input)
        
        return Doc.error(atLine: line, expected: message, actual: actual)
    }
    
    static func error(_ err: ParseError) -> Doc {
        Doc.error(atLine: err.line, expected: err.expected, actual: err.actual)
    }
}


extension Parsers {
    struct FunctionParser: Parser {
        func parse(_ input: inout TextDocument) -> Doc? {
            let original = input
            guard let signature = DocLine(FunctionSignature.parser()).parse(&input),
                  let deprecated = DocLine(deprecable("Function")).parse(&input)
            else {
                input = original
                return nil
            }
            
            guard let description = DescriptionDoc.parser().parse(&input) else {
                return .error(
                    expected: "Function `\(signature.fullName)` to have a description",
                    actual: &input
                )
            }
            
            let parameters: ParametersDoc!
            switch ParametersDoc.parser().parse(&input) {
            case .none:
                return .error(
                    expected: "Function `\(signature.fullName)` to have \"Parameters:\"",
                    actual: &input
                )
            case .failure(let err):
                return .error(err)
            case .success(let result):
                parameters = result
            }
            
            let returns: ReturnsDoc!
            switch ReturnsDoc.parser().parse(&input) {
            case .none:
                return .error(
                    expected: "Function `\(signature.fullName)` to have \"Returns:\"",
                    actual: &input
                )
            case .failure(let err):
                return .error(err)
            case .success(let result):
                returns = result
            }
            
            let notes: NotesDoc?
            switch NotesDoc.parser().parse(&input) {
            case .none:
                notes = nil
            case .success(let result):
                notes = result
            case .failure(let err):
                return .error(err)
            }
            
            if let lastLine = input.first?.number,
               let extras = allDocLines.parse(&input),
               !extras.isEmpty
            {
                return .error(
                    atLine: lastLine,
                    expected: "Function `\(signature.fullName)` to have ended",
                    actual: extras
                )
            }
            
            return Doc.function(
                signature: signature,
                deprecated: deprecated,
                description: description,
                parameters: parameters,
                returns: returns,
                notes: notes
            )
        }
    }
    
}
