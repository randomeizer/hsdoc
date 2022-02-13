import HSDocKit
import NonEmpty
import SwiftUI

/// Defines a module of functions/methods/etc.
public class Module {
    /// The name of the ``Module``.
    public let name: ModuleSignature
    
    /// The documentation for the ``Module``.
    public let details: ModuleDetailsDoc
    
    public init(name: ModuleSignature, details: ModuleDetailsDoc) {
        self.name = name
        self.details = details
    }
    
    public convenience init?(doc: Doc) {
        guard case let .module(name: name, details: details) = doc else {
            return nil
        }
        
        self.init(name: name, details: details)
    }
    
    /// The list of all items (fields/variables/methods/etc) for the module.
    public var items: [ModuleItem] = []
    
    /// The list of fields defined for the module.
    public var fields: [ModuleItem] {
        items.filter {
            switch $0 {
            case .field:
                return true
            default:
                return false
            }
        }
    }
    
    /// The list of functions defined for the module.
    public var functions: [ModuleItem] {
        items.filter {
            switch $0 {
            case .function:
                return true
            default:
                return false
            }
        }
    }
    
    /// The list of methods defined for the module.
    public var methods: [ModuleItem] {
        items.filter {
            switch $0 {
            case .method:
                return true
            default:
                return false
            }
        }
    }
    
    /// The list of variables defined for the module.
    public var variables: [ModuleItem] {
        items.filter {
            switch $0 {
            case .variable:
                return true
            default:
                return false
            }
        }
    }
}

extension Module: CustomStringConvertible {
    public var description: String {
        """
        
        ============================
        Module: \(name)
        Items:
        \(items.map { $0.description }.joined(separator: "\n\n"))
        ============================
        """
    }
}
