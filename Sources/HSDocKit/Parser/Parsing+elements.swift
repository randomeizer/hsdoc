//
//  Parsing+elements.swift
//  HSDoc
//
//  Created by David Peterson on 31/12/21.
//

import Parsing

// Parsers for whitespace
let optionalSpace = Prefix(minLength: 0, maxLength: 1, while: { $0 == " " })
let optionalSpaces = Prefix(minLength: 0, while: { $0 == " " })
let oneOrMoreSpaces = Prefix(minLength: 1, while: { $0 == " " })

// Parsers for newlines
let optionalNewline = Prefix(minLength: 0, maxLength: 1, while: {$0 == "\n" })
let nonNewlineCharacters = Prefix { $0 != "\n" }

let itemPathSeparator: Character = "."
let methodPathSeparator: Character = ":"

// Parses comma separators, allowing for optional spaces either side.
let commaSeparator = Parse {
    Skip { optionalSpaces }
    ","
    Skip { optionalSpaces }
}

/// Parses if the next input is either a `"\n"` or there is no further input.
let endOfLineOrInput = OneOf {
    "\n"
    End()
}
