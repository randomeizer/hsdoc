import Quick
import Nimble
@testable import HSDocKit

class ParserElementsSpec: QuickSpec {
    override func spec() {
        describe("elements") {
            context("docPrefix") {
                given (
                    ("three slashes",       "///",  true,   "",     #line),
                    ("three slashes space", "/// ", true,   "",     #line),
                    ("three dashes",        "---",  true,   "",     #line),
                    ("three dashes space",  "--- ", true,   "",     #line),
                    ("two dashes",          "--",   false,  "--",   #line),
                    ("four dashes",         "----", false,  "----", #line),
                    ("two slashes",         "//",   false,  "//",   #line),
                    ("four slashes",        "////", false,  "////", #line),
                    ("slash dash",          "///-", true,   "-",    #line),
                    ("dash slash",          "---/", true,   "/",    #line)
                ) { (label, input, parses, remainder, line: UInt) in
                    
                    it("\(parses.succeedsOrFails) parsing \(label)") {
                        var inputSub = input[...]
                        
                        expect{ try docPrefix.parse(&inputSub) }.to(throwError(if: !parses))
                        expect(line: line, inputSub).to(equal(remainder[...]))
                    }
                }
            }
        }
    }
}
