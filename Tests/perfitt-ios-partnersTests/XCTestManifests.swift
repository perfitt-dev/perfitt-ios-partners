import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(perfitt_ios_partnersTests.allTests),
    ]
}
#endif
