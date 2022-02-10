//
//  Parsing+elements.swift
//  HSDoc
//
//  Created by David Peterson on 31/12/21.
//

import Parsing

// Parsers for whitespace
let optionalSpace = Prefix(0...1) { $0 == " " }
let optionalSpaces = Prefix(0...) { $0 == " " }
let oneOrMoreSpaces = Prefix(1...) { $0 == " " }

let nonBlank = Parse {
    Check {
        optionalSpaces
        Prefix(1)
    } orThrow: { _, _ in
        LintError.expected("at least one non-whitespace character")
    }
    Rest()
}

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

let blankDocLine = DocLine {
    Skip { optionalSpaces }
}

// Parses at least one blank documentation line ("///")
let blankDocLines = Skip {
    OneOrMore {
        blankDocLine
    }
}

/// matches either one or more blank doc lines, a non-doc line, or the end of input.
let blankDocLinesOrEnd = OneOf {
    blankDocLines
    Check { NonDocLine() }
    End<TextDocument>()
}

/// matches any doc line with at least one non-whitespace character after the prefix.
let nonBlankDocLine = DocLine { nonBlank }
