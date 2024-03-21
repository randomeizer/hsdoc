/// Describes an issue with the formatting or data within documentation
public enum LintError: Error {
    case expected(String)
}

extension LintError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .expected(let description):
            return "expected \(description)"
        }
    }
}
