import Foundation
import Parsing

/// A line of text in a sequence, with the line number.
struct TextLine: Equatable {
    let number: UInt
    let text: Substring
    
    init(_ number: UInt, text: Substring) {
        self.number = number
        self.text = text
    }
}
