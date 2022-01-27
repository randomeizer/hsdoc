//
//  Parsing+elements.swift
//  HSDoc
//
//  Created by David Peterson on 31/12/21.
//

import Foundation
import NonEmpty
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
    Skip(optionalSpaces)
    ","
    Skip(optionalSpaces)
}

// Parses documentation comment prefixes, including a single optional space.
let docPrefix = Parse {
    OneOf {
        Parse { // ObjC
            "///"
            Not { "/" }
        }
        Parse { // Lua
            "---"
            Not { "-" }
        }
    }
    Skip(optionalSpace)
}

/// Parses if the next input is either a `"\n"` or there is no further input.
let endOfLineOrInput = OneOf {
    "\n"
    End()
}

/// Parses a single 'documentation' comment line, starting with `///` or `---` and ending with a newline
/// The `Upstream` ``Parser`` will only be passed the contents of a single line, excluding the header and the newline.
/// It must consume the whole contents of the line, other than trailing whitespace.
//struct DocLine<Upstream>: Parser where Upstream: Parser, Upstream.Input == Substring {
//    let upstream: Upstream
//
//    init(_ upstream: Upstream) {
//        self.upstream = upstream
//    }
//
//    init(@ParserBuilder upstream: () -> Upstream) {
//        self.upstream = upstream()
//    }
//
//    func parse(_ input: inout Substring) -> Upstream.Output? {
//        Parse {
//            docPrefix
//            nonNewlineCharacters
//            endOfLineOrInput
//        }
//        .pipe(Parse {
//            upstream
//            Skip(optionalSpaces)
//            End()
//        })
//        .parse(&input)
//    }
//}

// Parses at least one blank documentation line ("///")
let blankDocLines = Skip(Many(atLeast: 1) { DocLine("") })

// MARK: Doc

//let nonDocLines = Parse {
//    Many {
//        nonDocLine
//    } separator: {
//        "\n"
//    }
//    Skip { optionalNewline }
//}
//.map { $0.count }

struct NonDocLine: Parser {
    func parse(_ input: inout TextDocument) -> Void? {
        guard let firstLine = input.first else {
            return nil
        }
        
        var text = firstLine.text
        
        guard docPrefix.parse(&text) == nil else {
            return nil
        }
        
        input = input.dropFirst()
        return ()
    }
}

struct NonDocLines: Parser {
    func parse(_ input: inout TextDocument) -> UInt? {
        let nonDocLine = NonDocLine()
        var count: UInt = 0
        
        while nonDocLine.parse(&input) != nil {
            count = count + 1
        }
        
        return count
    }
}

//let nonDocLines = Many {
//    NonDocLine()
//}
//.map { $0.count }
