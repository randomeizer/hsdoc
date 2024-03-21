import Quick
import Nimble
@testable import HSDocKit

class ParameterSignatureSpec: QuickSpec {
    override class func spec() {
        describe("ParameterSignature") {
            context("parser") {
                let parser = ParameterSignature.parser
                
                itParses("required") {
                    "foo"[...]
                } with: {
                    parser
                } to: {
                    ParameterSignature(name: "foo", isOptional: false)
                }
                
                itParses("optional") {
                    "[foo]"[...]
                } with: {
                    parser
                } to: {
                    ParameterSignature(name: "foo", isOptional: true)
                }
                
                itFailsParsing("unclosed optional") {
                    "[foo"[...]
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: multiple failures occurred
                    
                    error: unexpected input
                     --> input:1:5
                    1 | [foo
                      |     ^ expected "]"
                    
                    error: expected letter or underscore
                     --> input:1:1
                    1 | [foo
                      | ^
                    """
                }
                
                itParses("unopened optional") {
                    "foo]"
                } with: {
                    parser
                } to: {
                    .init(name: "foo", isOptional: false)
                } leaving: {
                    "]"
                }
                
                itParses("full") {
                    "_foo123"
                } with: {
                    parser
                } to: {
                    .init(name: "_foo123", isOptional: false)
                }
                
                itFailsParsing("number") {
                    "123_foo"
                } with: {
                    parser
                } withErrorMessage: {
                    """
                    error: multiple failures occurred
                    
                    error: unexpected input
                     --> input:1:1
                    1 | 123_foo
                      | ^ expected "["
                    
                    error: expected letter or underscore
                     --> input:1:1
                    1 | 123_foo
                      | ^
                    """
                }
                
                it("is described correctly") {
                    expect(ParameterSignature(name: "foo", isOptional: false).description).to(equal("foo"))
                    expect(ParameterSignature(name: "foo", isOptional: true).description).to(equal("[foo]"))
                }
                
                context("list") {
                    let parser = ParameterSignature.listParser
                    
                    itParses("empty") {
                        "()"
                    } with: {
                        parser
                    } to: {
                        []
                    } leaving: {
                        ""
                    }
                    
                    itParses("one") {
                        "(foo)"
                    } with: {
                        parser
                    } to: {
                        [.init(name: "foo")]
                    }
                    
                    itParses("two") {
                        "(foo, bar)"
                    } with: {
                        parser
                    } to: {
                        [.init(name: "foo"), .init(name: "bar")]
                    }
                    
                    itParses("optional") {
                        "([foo])"
                    } with: {
                        parser
                    } to: {
                        [.init(name: "foo", isOptional: true)]
                    }
                    
                    itParses("mixed") {
                        "(foo, [bar])"
                    } with: {
                        parser
                    } to: {
                        [.init(name: "foo"), .init(name: "bar", isOptional: true)]
                    }
                    
                    itFailsParsing("extra comma") {
                        "(foo,)"
                    } with: {
                        parser
                    } withErrorMessage: {
                        return """
                        error: multiple failures occurred
                        
                        error: unexpected input
                         --> input:1:6
                        1 | (foo,)
                          |      ^ expected "["
                        
                        error: expected letter or underscore
                         --> input:1:6
                        1 | (foo,)
                          |      ^
                        
                        error: unexpected input
                         --> input:1:5
                        1 | (foo,)
                          |     ^ expected ")"
                        """
                    } leaving: {
                        ",)"
                    }
                }
            }
        }
    }
}
