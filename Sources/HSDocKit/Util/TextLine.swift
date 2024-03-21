import Foundation
import Parsing

/// A line of text in a sequence, with the line number.
public struct TextLine: Equatable {
    public let number: UInt
    public let text: Substring
    
    init(_ number: UInt, text: Substring) {
        self.number = number
        self.text = text
    }
}
