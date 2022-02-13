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
    static let parser = Try {
        OneOf {
            moduleParser
            itemParser
        }
    } catch: { error in
        Doc.error(message: "\(error)")
    }
    
    /// Parses a 'Module'
    static let moduleParser = Parse(Self.module) {
        DocLine {
            "=== "
            ModuleSignature.nameParser
            " ==="
        }
        ModuleDetailsDoc.parser
    }
    
    static let itemParser = Parse(Self.item) {
        ModuleItem.parser
    }
}
