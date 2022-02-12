import HSDocKit
import NonEmpty
import SwiftUI

/// Defines a module of functions/methods/etc.
public class Module {
    /// The name of the ``Module``.
    public let name: ModuleSignature
    
    /// The documentation for the ``Module``.
    public let description: ModuleDescriptionDoc
    
    public init(name: ModuleSignature, description: ModuleDescriptionDoc) {
        self.name = name
        self.description = description
    }
    
    public convenience init?(doc: Doc) {
        guard case let .module(name: name, description: description) = doc else {
            return nil
        }
        
        self.init(name: name, description: description)
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
