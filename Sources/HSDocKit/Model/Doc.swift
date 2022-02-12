import NonEmpty
/// Defines the options for documentation segments.
public enum Doc: Equatable {
    enum Prefix: String, CustomStringConvertible {
        case lua = "---"
        case objc = "///"
        
        var description: String {
            rawValue
        }
    }
    
    case module(
        name: ModuleSignature,
        description: ModuleDescriptionDoc
    )
    
    case function(
        signature: FunctionSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    )
    
    case constant(
        signature: ConstantSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    )

    case variable(
        signature: VariableSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    )
    
    case constructor(
        signature: ConstructorSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    )
    
    case method(
        signature: MethodSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        parameters: ParametersDoc,
        returns: ReturnsDoc,
        notes: NotesDoc? = nil
    )
    
    case field(
        signature: FieldSignature,
        deprecated: Bool = false,
        description: DescriptionDoc,
        notes: NotesDoc? = nil
    )
    
    case unrecognised(
        lines: Lines
    )
}

extension Doc: CustomStringConvertible {
    func text(for prefix: Prefix) -> String {
        switch self {
        case let .module(name: name, description: description):
            return """
            \(prefix) === \(name) ===
            \(prefix)
            \(description.text(for: prefix))
            """
            
        case let .function(signature: signature, deprecated: deprecated, description: description, parameters: parameters, returns: returns, notes: notes):
            var result = """
            \(prefix) \(signature)
            \(prefix) \(deprecated ? "Deprecated" : "Function")
            \(description.text(for: prefix))
            \(parameters.text(for: prefix))
            \(returns.text(for: prefix))
            """
            if let notes = notes {
                result.append("\n\(notes.text(for: prefix))")
            }
            return result

        case let .constant(signature: signature, deprecated: deprecated, description: description, notes: notes):
            var result = """
            \(prefix) \(signature)
            \(prefix) \(deprecated ? "Deprecated" : "Constant")
            \(description.text(for: prefix))
            """
            if let notes = notes {
                result.append("\n\(notes.text(for: prefix))")
            }
            return result

        case let .variable(signature: signature, deprecated: deprecated, description: description, notes: notes):
            var result = """
            \(prefix) \(signature)
            \(prefix) \(deprecated ? "Deprecated" : "Variable")
            \(description.text(for: prefix))
            """
            if let notes = notes {
                result.append("\n\(notes.text(for: prefix))")
            }
            return result
            
        case let .constructor(signature: signature, deprecated: deprecated, description: description, parameters: parameters, returns: returns, notes: notes):
            var result = """
            \(prefix) \(signature)
            \(prefix) \(deprecated ? "Deprecated" : "Function")
            \(description.text(for: prefix))
            \(parameters.text(for: prefix))
            \(returns.text(for: prefix))
            """
            if let notes = notes {
                result.append("\n\(notes.text(for: prefix))")
            }
            return result

        case let .method(signature: signature, deprecated: deprecated, description: description, parameters: parameters, returns: returns, notes: notes):
            var result = """
            \(prefix) \(signature)
            \(prefix) \(deprecated ? "Deprecated" : "Method")
            \(description.text(for: prefix))
            \(parameters.text(for: prefix))
            \(returns.text(for: prefix))
            """
            if let notes = notes {
                result.append("\n\(notes.text(for: prefix))")
            }
            return result
            
        case let .field(signature: signature, deprecated: deprecated, description: description, notes: notes):
            var result = """
            \(prefix) \(signature)
            \(prefix) \(deprecated ? "Deprecated" : "Field")
            \(description.text(for: prefix))
            """
            if let notes = notes {
                result.append("\n\(notes.text(for: prefix))")
            }
            return result

        case .unrecognised(lines: let lines):
            return "\(prefix) \(lines.joined(separator: "\n\(prefix) "))"
        }
    }
    
    public var description: String {
        text(for: .lua)
    }
}

extension NonEmpty where Element == ParagraphDoc {
    var description: String {
        var result = ""
        for item in self {
            result = result.appending(String(describing: item))
            result = result.appending("\n\n")
        }
        return result
    }
}
