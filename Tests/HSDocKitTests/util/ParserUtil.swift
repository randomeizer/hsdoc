//
//  ParserUtil.swift
//
//
//  Created by David Peterson on 12/1/22.
//

import CustomDump
import HSDocKit
import Nimble
import Parsing
import Quick

// MARK: itParses

extension QuickSpec {
    class func itParses<P: Parser>(
        _ label: String,
        file: FileString = #file,
        line: UInt = #line,
        from input: P.Input,
        with parser: () -> P,
        to output: P.Output?,
        leaving remainder: P.Input = P.Input()
    ) where P.Input: RangeReplaceableCollection & Equatable,
        P.Output: Equatable {
        let parser = parser()

        it("\((output != nil).succeedsOrFails) parsing \(label)") {
            var inputSub = input
            expect(file: file, line: line) {
                let actual = try parser.parse(&inputSub)

                if output == nil {
                    expect(file: file, line: line, actual).to(beNil(), description: "expected")
                } else {
                    expect(file: file, line: line, actual).to(haveNoDifference(to: output), description: "expected")
                }
            }.to(throwError(if: output == nil))

            expect(file: file, line: line, inputSub).to(haveNoDifference(to: remainder), description: "remainder mismatch")
        }
    }

    class func itParses<P: Parser>(
        _ label: String,
        file: FileString = #file,
        line: UInt = #line,
        from input: () -> P.Input,
        with parser: () -> P,
        to expected: () -> P.Output,
        leaving remainder: () -> P.Input = { P.Input() }
    ) where P.Input: RangeReplaceableCollection & Equatable,
        P.Output: Equatable {
        itParses(
            label,
            file: file,
            line: line,
            from: input(),
            with: parser,
            to: expected(),
            leaving: remainder()
        )
    }

    /// Parses the given input to the expected output with the given parser.
    class func itParses<P: Parser>(
        _ label: String,
        file: FileString = #file,
        line: UInt = #line,
        from input: P.Input,
        with parser: () -> P,
        to expected: P.Output,
        leaving remainder: String = ""
    ) where P.Input == Substring, P.Output: Equatable {
        itParses(
            label,
            file: file,
            line: line,
            from: input[...],
            with: parser,
            to: expected,
            leaving: remainder[...]
        )
    }

    /// Parses the given input to the expected output with the given parser.
    class func itParses<P: Parser>(
        _ label: String,
        file: FileString = #file,
        line: UInt = #line,
        from input: () -> P.Input,
        with parser: () -> P,
        to expected: () -> P.Output,
        leaving remainder: () -> P.Input
    ) where P.Input == Substring, P.Output: Equatable {
        itParses(
            label,
            file: file,
            line: line,
            from: input(),
            with: parser,
            to: expected(),
            leaving: remainder()
        )
    }
}

// MARK: - ifFailsParsing

extension QuickSpec {
    class func itFailsParsing<P: Parser>(
        _ label: String,
        file: FileString = #file,
        line: UInt = #line,
        from input: @escaping () -> P.Input,
        with parser: () -> P,
        withError: @escaping (Error) -> Void,
        leaving remainder: @escaping () -> P.Input
    ) where P.Output: Equatable, P.Input: RangeReplaceableCollection & Equatable {
        let parser = parser()

        it("fails parsing \(label)") {
            var inputSub = input()
            do {
                let output = try parser.parse(&inputSub)
                fail("expected to fail but got: \(output)", file: file, line: line)
            } catch {
                withError(error)
            }
            expect(file: file, line: line, inputSub).to(haveNoDifference(to: remainder()), description: "remainder")
        }
    }

    class func itFailsParsing<P: Parser>(
        _ label: String,
        from input: @escaping () -> P.Input,
        with parser: () -> P,
        withError: @escaping (Error) -> Void,
        file: FileString = #file,
        line: UInt = #line
    ) where P.Input: RangeReplaceableCollection & Equatable, P.Output: Equatable {
        itFailsParsing(
            label,
            from: input,
            with: parser,
            withError: withError,
            leaving: input
        )
    }

    class func itFailsParsing<P: Parser>(
        _ label: String,
        file: FileString = #file,
        line: UInt = #line,
        from input: @escaping () -> P.Input,
        with parser: () -> P,
        withErrorMessage: @escaping () -> String,
        leaving remainder: @escaping () -> P.Input
    ) where P.Input: RangeReplaceableCollection & Equatable,
        P.Output: Equatable {
        itFailsParsing(
            label,
            file: file,
            line: line,
            from: input,
            with: parser,
            withError: { error in
                expect(file: file, line: line, "\(error)").to(haveNoDifference(to: withErrorMessage()))
            },
            leaving: remainder
        )
    }

    class func itFailsParsing<P: Parser>(
        _ label: String,
        file: FileString = #file,
        line: UInt = #line,
        from input: @escaping () -> P.Input,
        with parser: () -> P,
        withErrorMessage: @escaping () -> String
    ) where P.Input: RangeReplaceableCollection & Equatable,
        P.Output: Equatable {
        itFailsParsing(
            label,
            file: file,
            line: line,
            from: input,
            with: parser,
            withErrorMessage: withErrorMessage,
            leaving: input
        )
    }
}
