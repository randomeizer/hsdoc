//
//  ParserUtil.swift
//  
//
//  Created by David Peterson on 12/1/22.
//

import Quick
import Nimble
import Parsing
import CustomDump


/// Parses the given input to the expected output with the given parser.
func itParses<P,Output>(_ label: String, with parser: P, from input: String, to expected: Output?, leaving remainder: String = "", file: FileString = #file, line: UInt = #line)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    it("\((expected != nil).succeedsOrFails) parsing \(label)") {
        var inputSub = input[...]
        let actual = parser.parse(&inputSub)
        
        if expected == nil {
            expect(file: file, line: line, actual).to(beNil(), description: "to")
        } else {
            #warning("Create a Nimble expectation to use customDump")
            XCTAssertNoDifference(actual, expected, "to", file: file, line: line)
//            expect(file: file, line: line, actual).to(equal(expected), description: "to")
        }
        
        expect(file: file, line: line, inputSub).to(equal(remainder[...]), description: "leaving")
    }
}

/// Parses the given input to the expected output with the given parser.
func itParses<P,Output>(_ label: String, with parser: P, file: FileString = #file, line: UInt = #line, from input: () -> String, to expected: () -> Output?, leaving remainder: () -> String = {""})
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    itParses(label, with: parser, from: input(), to: expected(), leaving: remainder(), file: file, line: line)
}

func itFailsParsing<P,Output>(_ label: String, with parser: P, from input: String, file: FileString = #file, line: UInt = #line)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    itParses(label, with: parser, from: input, to: nil, leaving: input, file: file, line: line)
}

func itFailsParsing<P,Output>(_ label: String, with parser: P, file: FileString = #file, line: UInt = #line, from input: () -> String)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    let input = input()
    itParses(label, with: parser, from: input, to: nil, leaving: input, file: file, line: line)
}
