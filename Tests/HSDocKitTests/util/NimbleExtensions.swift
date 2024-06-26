import CustomDump
import Foundation
import Nimble

/// This can then be used to provide multiple examples of data to iterate tests over.
///
/// For example, this will result in three different tests occurring:
///
/// ```swift
/// given(
///     (1, plus: 1, is: 2),
///     (1, plus: 2, is: 2),
///     (1, plus: 3, is: 4)
/// ) { (a, b, result) in
///     it("\(a) plus \(b) is \(result)") {
///         expect(a + b).to(equal(result))
///     }
/// }
/// ```
///
/// In this case, the second item (1 plus 2) has an error in the data, and will fail on the `expect` line, since `1 + 2 != 2`.
///
/// In this case, the error itself won't indicate which line of data failed, but you can tell from the generated `it` test name, since it interpolates the values into the title, which in this case would report that `1_plus_2_is_2()` failed. However, if you want to get more specific, you can use the `#line` feature of Swift to grab the line number, then pass it to `expect` to report the specific line, like so:
///
/// ```swift
/// given(
///     (1, plus: 1, is: 2, line: #line),
///     (1, plus: 2, is: 2, line: #line),
///     (1, plus: 3, is: 4, line: #line)
/// ) { (a, b, result, line: UInt) in
///     it("\(a) plus \(b) is \(result)") {
///         expect(line: line, a + b).to(equal(result))
///     }
/// }
/// ```
///
/// *Note:* It's important to specify `line: UInt` in the input signature, since `UInt` is the type that the `expect` function requires for its `line:` parameter.
///
/// This will now highlight the second row of data as failing instead of the `expect` line.
///
/// - Parameter data: The list of input data to iterate over.
/// - Parameter then: The closure that will be called for each data item.
public func given<Data>(_ data: Data..., then: (_: Data) -> Void) {
    for item in data { then(item) }
}

/// A Nimble predicate function which will expect an error to be thrown if the `if` parameter is `true`, otherwise it will expect no error to be thrown.
///
/// This is handy if you want to optionally expect an error based on a boolean/checkable value. This is particularly handy with data-driven testing, since it allows you to specify the output will or will not throw an error given differen sets of inputs.
///
/// - Parameter if: if `true`, expect an error to be thrown, otherwise no error should be thrown.
///
/// - Returns: The `Predicate` result.
public func throwError<Out>(if failed: Bool) -> Nimble.Matcher<Out> {
    if failed {
        return throwError()
    } else {
        return Matcher { _ in
            MatcherResult(
                bool: true,
                message: .expectedActualValueTo("succeed")
            )
        }
    }
}

/// A Nimble predicate function which will expect an assertion  to be thrown if the `if` parameter is `true`, otherwise it will expect no error to be thrown.
/// This is handy if you want to optionally expect an assertion based on a boolean/checkable value.
///
/// This is particularly handy with data-driven testing, since it allows you to pass in a boolean that can then easily be checked to determine an assertion result. For example:
///
/// ```swift
/// given(
///    (1, dividedBy: 1, fails: false),
///    (1, dividedBy: 0, fails: true)
/// ) { (numerator, denominator, fails) in
///    let failsOrSucceeds = fails ? "fails" : "succeeds"
///    it("\(failsOrSucceeds) when given \(numerator) divided by \(denominator)") {
///        expect {
///            let result = numerator / denominator
///        }.to(throwAssertion(if: fails))
///    }
/// }
/// ```
///
/// - Parameter if: if `true`, expect an error to be thrown, otherwise no error should be thrown.
public func throwAssertion<Out>(if failed: Bool) -> Nimble.Matcher<Out> {
    if failed {
        return throwAssertion()
    } else {
        return Matcher { _ in
            MatcherResult(
                bool: true,
                message: .expectedActualValueTo("succeed")
            )
        }
    }
}

public func always<T>(_ predicate: Matcher<T>, when condition: @autoclosure () -> Bool)
    -> Nimble.Matcher<T> {
    if condition() {
        return predicate
    }

    return Matcher.define { actualExpression in
        var msg: ExpectationMessage
        if let actualValue = try actualExpression.evaluate() {
            msg = .expectedCustomValueTo(
                "always be ignored",
                actual: "\(actualValue)"
            )
        } else {
            msg = .expectedActualValueTo(
                "always be ignored"
            )
        }

        return MatcherResult(bool: true, message: msg)
    }
}

extension SyncExpectation {
    /// Tests the actual value using a matcher to match.
    /// If `when` resolves to `true`, the `predicate` will be run, otherwise it will be ignored.
    @discardableResult
    public func to(
        _ predicate: Matcher<Value>, when condition: @autoclosure () -> Bool, description: String? = nil
    ) -> Self {
        return to(always(predicate, when: condition()), description: description)
    }

    /// Tests the actual value using a matcher to not match.
    /// If `when` resolves to `true`, the `predicate` will be run, otherwise it will be ignored.
    @discardableResult
    public func toNot(
        _ predicate: Matcher<Value>, when condition: @autoclosure () -> Bool, description: String? = nil
    ) -> Self {
        return to(always(predicate, when: !condition()), description: description)
    }

    /// Tests the actual value using a matcher to not match.
    /// If `when` resolves to `true`, the `predicate` will be run, otherwise it will be ignored.
    ///
    /// Alias to toNot().
    @discardableResult
    public func notTo(
        _ predicate: Matcher<Value>, when condition: @autoclosure () -> Bool, description: String? = nil
    ) -> Self {
        return toNot(predicate, when: condition(), description: description)
    }
}

// Nimble extension for `haveNoDifference` and `haveDifference` which use the `customDump` and `diff` functions
// from the PointFree 'swift-custom-dump' (https://github.com/pointfreeco/swift-custom-dump) library.

public func haveNoDifference<T>(
    to expectedValue: T
) -> Matcher<T> {
    return Matcher<T> { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: .fail("have a value"))
        }
        
        guard let difference = diff(expectedValue, actualValue) else {
            return MatcherResult(status: .matches, message: .expectedTo("have no difference"))
        }
        return MatcherResult(status: .fail, message: .fail("expected to have no difference, but found:\n\(difference)"))
    }
}

public func haveDifference<T>(
    from expectedValue: T
) -> Nimble.Matcher<T> {
    return Nimble.Matcher<T> { actualExpression in
        guard let actualValue = try actualExpression.evaluate() else {
            return MatcherResult(status: .fail, message: .fail("have a value"))
        }
        
        guard diff(expectedValue, actualValue) != nil else {
            return MatcherResult(status: .fail, message: .expectedTo("to have a difference"))
        }
        return MatcherResult(status: .matches, message: .expectedTo("have a difference"))
    }
}
