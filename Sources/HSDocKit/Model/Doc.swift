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
        details: ModuleDetailsDoc
    )

    case item(ModuleItem)
    
    case error(message: String)
}

extension Doc: CustomStringConvertible {
    func text(for prefix: Prefix) -> String {
        switch self {
        case let .module(name: name, details: details):
            return """
            \(prefix) === \(name) ===
            \(prefix)
            \(details.text(for: prefix))
            """
        case let .item(item):
            return item.text(for: prefix)
        case let .error(message: message):
            return message
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
