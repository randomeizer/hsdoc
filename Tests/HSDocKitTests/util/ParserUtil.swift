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
import HSDocKit

// MARK: itParses

func itParses<P,Input,Output>(_ label: String, with parser: P, from input: Input, to expected: Output?, leaving remainder: Input = Input(), file: FileString = #file, line: UInt = #line)
where P: Parser, Input == P.Input, Output == P.Output, Output: Equatable, Input: RangeReplaceableCollection, Input: Equatable
{
    it("\((expected != nil).succeedsOrFails) parsing \(label)") {
        var inputSub = input
        expect(file: file, line: line) {
            let actual = try parser.parse(&inputSub)

            if expected == nil {
                expect(file: file, line: line, actual).to(beNil(), description: "to")
            } else {
                #warning("Create a Nimble expectation to use customDump")
                XCTAssertNoDifference(actual, expected, "to", file: file, line: line)
    //            expect(file: file, line: line, actual).to(equal(expected), description: "to")
            }
        }.to(throwError(if: expected == nil))
        
        XCTAssertNoDifference(inputSub, remainder, "remainder mismatch", file: file, line: line)
    }
}

func itParses<P,Input,Output>(_ label: String, with parser: P, from input: () -> Input, to expected: () -> Output?, leaving remainder: () -> Input = { Input() }, file: FileString = #file, line: UInt = #line)
where P: Parser, Input == P.Input, Output == P.Output, Output: Equatable, Input: RangeReplaceableCollection, Input: Equatable
{
    itParses(label, with: parser, from: input(), to: expected(), leaving: remainder(), file: file, line: line)
}

/// Parses the given input to the expected output with the given parser.
func itParses<P,Output>(_ label: String, with parser: P, from input: String, to expected: Output?, leaving remainder: String = "", file: FileString = #file, line: UInt = #line)
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    itParses(label, with: parser, from: input[...], to: expected, leaving: remainder[...], file: file, line: line)
}

/// Parses the given input to the expected output with the given parser.
func itParses<P,Output>(_ label: String, with parser: P, file: FileString = #file, line: UInt = #line, from input: () -> String, to expected: () -> Output?, leaving remainder: () -> String = {""})
where P: Parser, P.Input == Substring, Output == P.Output, Output: Equatable
{
    itParses(label, with: parser, from: input(), to: expected(), leaving: remainder(), file: file, line: line)
}

// MARK: ifFailsParsing

func itFailsParsing<P,Input,Output>(_ label: String, with parser: P, from input: @escaping () -> Input, withError: @escaping (Error) -> Void, leaving remainder: @escaping () -> Input, file: FileString = #file, line: UInt = #line)
where P: Parser, Input == P.Input, Output == P.Output, Output: Equatable, Input: RangeReplaceableCollection, Input: Equatable
{
    it("fails parsing \(label)") {
        var inputSub = input()
        do {
            let output = try parser.parse(&inputSub)
            fail("expected to fail but got: \(output)", file: file, line: line)
        } catch {
            withError(error)
        }
        expect(file: file, line: line, inputSub).to(equal(remainder()), description: "remainder")
    }
}

func itFailsParsing<P,Input,Output>(_ label: String, with parser: P, from input: @escaping () -> Input, withError: @escaping (Error) -> Void, file: FileString = #file, line: UInt = #line)
where P: Parser, Input == P.Input, Output == P.Output, Output: Equatable, Input: RangeReplaceableCollection, Input: Equatable
{
    itFailsParsing(label, with: parser, from: input, withError: withError, leaving: input)
}

func itFailsParsing<P,Input,Output>(_ label: String, with parser: P, from input: @escaping () -> Input, withErrorMessage: @escaping () -> String, leaving remainder: @escaping () -> Input, file: FileString = #file, line: UInt = #line)
where P: Parser, Input == P.Input, Output == P.Output, Output: Equatable, Input: RangeReplaceableCollection, Input: Equatable
{
    itFailsParsing(label, with: parser, from: input, withError: { error in
        XCTAssertNoDifference("\(error)", withErrorMessage(), file: file, line: line)
    }, leaving: remainder, file: file, line: line)
}

func itFailsParsing<P,Input,Output>(_ label: String, with parser: P, from input: @escaping () -> Input, withErrorMessage: @escaping () -> String, file: FileString = #file, line: UInt = #line)
where P: Parser, Input == P.Input, Output == P.Output, Output: Equatable, Input: RangeReplaceableCollection, Input: Equatable
{
    itFailsParsing(label, with: parser, from: input, withErrorMessage: withErrorMessage, leaving: input, file: file, line: line)
}
