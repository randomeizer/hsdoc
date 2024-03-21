import Parsing
import Dispatch

func deprecable<P>(_ match: P) -> Try<Substring, Bool, OneOf<Substring, Bool, OneOfBuilder<Substring, Bool>.OneOf2<Parsers.Map<P, Bool>, Parsers.MapConstant<String, Bool>>>>
where P: Parser, P.Input == Substring
{
    Try {
        OneOf {
            match.map { _ in false }
            "Deprecated".map { true }
        }
    } catch: { error in
        throw LintError.expected("\(match) or Deprecated")
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
    .eraseToAnyParser()
    
    static let itemParser = Parse(Self.item) {
        ModuleItem.parser
    }
}
