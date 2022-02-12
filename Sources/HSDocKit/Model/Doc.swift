import NonEmpty
import Foundation
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

    case item(ModuleItem)
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
        case let .item(item):
            return item.text(for: prefix)
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
