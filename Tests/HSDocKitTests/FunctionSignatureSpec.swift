import Quick
import Nimble
@testable import HSDocKit

class FunctionSignatureSpec: QuickSpec {
    override func spec() {
        describe("FunctionSignature") {
            context("parser") {
                let parser = FunctionSignature.parser
                
                itParses("function with params and returns", with: parser) {
                    "foo.bar(a, b) -> table, number"
                } to: {
                    FunctionSignature(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a"), .init(name: "b")],
                        returns: ["table", "number"]
                    )
                }
                
                itParses("function with optional param", with: parser) {
                    "foo.bar([a])"
                } to: {
                    .init(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a", isOptional: true)]
                    )
                }
                
                it("is described correctly with return values") {
                    let value = FunctionSignature(
                        module: .init("foo"), name: "bar",
                        parameters: [.init(name: "a"), .init(name: "b", isOptional: true)],
                        returns: ["table", "number"]
                    )
                    
                    expect(value.description).to(equal("foo.bar(a, [b]) -> table, number"))
                }
                
                it("is described correctly with no params or return values") {
                    let value = FunctionSignature(module: .init("foo"), name: "bar")
                    
                    expect(value.description).to(equal("foo.bar()"))
                }
            }
        }
    }
}
