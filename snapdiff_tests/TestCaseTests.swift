//
//  TestCaseTests.swift
//  snapdiff
//
//  Created by Joe Conway on 08/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import XCTest
@testable import snapdiff

let fixtureStartLine = "Test Case '-[SomeTests testAThing]' started."
let fixturePassedLine = "Test Case '-[SomeTests testAThing]' passed."
let fixtureFailedLine = "Test Case '-[SomeTests testAThing]' failed."
let fixtureDiffLine  = "ksdiff \"reference.png\" \"failed.png\""

fileprivate struct FixtureParser {
    static func fixtureLine(_ type: LineType) -> String {
        switch type {
        case .testStart:
            return fixtureStartLine
        case .testPass:
            return fixturePassedLine
        case .testFail:
            return fixtureFailedLine
        case .diff:
            return fixtureDiffLine
        }
        
    }
    
    static func fixtureLines(_ types: [LineType]) -> [String] {
        var ret: [String] = []
        for type in types {
            ret.append(FixtureParser.fixtureLine(type))
        }
        return ret
    }
}

fileprivate typealias ParserTestsExtension = Parser
fileprivate extension ParserTestsExtension {
    mutating func parseMultipleLines(sequence: [LineType]) {
        let lines = FixtureParser.fixtureLines(sequence)
        for input in lines {
            _ = self.parse(input)
        }
    }
}

class LineTypeSpec: XCTestCase {
    func testParseLineTypeStartLine() {
        let type = LineType(rawValue: FixtureParser.fixtureLine(.testStart))
        XCTAssert(type == .testStart)
    }
    
    func testParseLineTypePassedLine() {
        let type = LineType(rawValue: FixtureParser.fixtureLine(.testPass))
        XCTAssert(type == .testPass)
    }
    
    func testParseLineTypeFailureLine() {
        let type = LineType(rawValue: FixtureParser.fixtureLine(.testFail))
        XCTAssert(type == .testFail)
    }
    
    func testParseLineTypeKSDiffLine() {
        let type = LineType(rawValue: FixtureParser.fixtureLine(.diff))
        XCTAssert(type == .diff)
    }
}

class ParserSpec: XCTestCase {
    
    func testParseTestCaseObjectWithSuccess() {
        let sequence = FixtureParser.fixtureLines([.testStart, .testPass])
        parseTestSequence(sequence) { result in
            XCTAssert(result != nil, "Parser should return a test object after parsing a test pass line.")
            XCTAssert(result?.passed == true, "A test with only a start and a pass line, should be considered passing")
        }
    }
    
    func testParseTestCaseObjectWithFailure() {
        let sequence = FixtureParser.fixtureLines([.testStart, .testFail])
        parseTestSequence(sequence) { result in
            XCTAssert(result != nil, "Parser should return a test object after parsing a test fail line.")
            XCTAssert(result?.passed == false, "A test with only a start and a pass line, should be considered passing")
            XCTAssert(result?.hasSnapshotFailures() == false, "A test with only a start and a fail, with no diff lines, should not consider itself to have snapshot failures")
        }
    }
    
    func testParseTestCaseObjectWithFailureWithDiff() {
        let sequence = FixtureParser.fixtureLines([.testStart, .diff, .testFail])
        parseTestSequence(sequence) { result in
            XCTAssert(result != nil, "Parser should return a test object after parsing a test fail line.")
            XCTAssert(result?.passed == false, "A test with only a start and a pass line, should be considered passing")
            XCTAssert(result?.hasSnapshotFailures() == true, "A test with only a start and a fail, with no diff lines, should not consider itself to have snapshot failures")
        }
    }
    
    func testParseTestCaseObjectWithFailureWithManyDiffs() {
        
        let sequence = FixtureParser.fixtureLines([.testStart, .diff, .diff, .testFail])
        parseTestSequence(sequence) { result in
            XCTAssert(result != nil, "Parser should return a test object after parsing a test fail line.")
            XCTAssert(result?.passed == false, "A test with only a start and a pass line, should be considered passing")
            XCTAssert(result?.hasSnapshotFailures() == true, "A test with only a start and a fail, with no diff lines, should not consider itself to have snapshot failures")
        }
    }
    
    
    
    func testGetFailingSnapshotTestsWithNoTests() {
        let parser = Parser()
        
        XCTAssert(parser.failedTestCases().count == 0)
        XCTAssert(parser.failedSnapshotTestCases().count == 0)
    }
    
    func testGetFailingSnapshotTestsWithOnlyPasses() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testPass,
                                .testStart, .testPass])
        
        XCTAssert(parser.failedTestCases().count == 0)
        XCTAssert(parser.failedSnapshotTestCases().count == 0)
        
    }
    
    func testGetFailingSnapshotTestsWithOnePassOneFailNoSnapshotFailures() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testPass,
                                .testStart, .testFail])
        
        XCTAssert(parser.failedTestCases().count == 1)
        XCTAssert(parser.failedSnapshotTestCases().count == 0)
    }
    
    func testGetFailingSnapshotTestsWithOnePassOneSnapshotFailures() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testPass,
                                .testStart, .diff, .testFail])
        
        XCTAssert(parser.failedTestCases().count == 1)
        XCTAssert(parser.failedSnapshotTestCases().count == 1)
    }
    
    
    func testGetFailingSnapshotTestsWithNoSnapshotFailures() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testFail,
                                .testStart, .testFail])
        
        XCTAssert(parser.failedTestCases().count == 2)
        XCTAssert(parser.failedSnapshotTestCases().count == 0)
    }
    
    func testGetFailingSnapshotTestsWithOneSnapshotTestWithOneSnapshotFailure() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testFail,
                                .testStart, .diff, .testFail])
        
        XCTAssert(parser.failedTestCases().count == 2)
        XCTAssert(parser.failedSnapshotTestCases().count == 1)
    }
    
    func testGetFailingSnapshotTestsWithOneSnapshotTestWithManySnapshotFailures() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testFail,
                                .testStart, .diff, .diff, .diff, .testFail])
        
        XCTAssert(parser.failedTestCases().count == 2)
        XCTAssert(parser.failedSnapshotTestCases().count == 1)
    }
    
    func testGetFailingSnapshotTestsWithThreeSnapshotTestsWithOneSnapshotFailure() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testFail,
                                .testStart, .diff, .testFail,
                                .testStart, .diff, .testFail,
                                .testStart, .diff, .testFail])
        
        XCTAssert(parser.failedTestCases().count == 4)
        XCTAssert(parser.failedSnapshotTestCases().count == 3)
    }
    func testGetFailingSnapshotTestsWithThreeSnapshotTestsWithManySnapshotFailures() {
        var parser = Parser()
        
        parser.parseMultipleLines(sequence: [.testStart, .testFail,
                                .testStart, .diff, .diff, .testFail,
                                .testStart, .diff, .diff, .diff, .testFail,
                                .testStart, .diff, .testFail])
        
        XCTAssert(parser.failedTestCases().count == 4)
        XCTAssert(parser.failedSnapshotTestCases().count == 3)
    }
    
    func parseTestSequence(_ sequence: [String], withExpectation completion: (TestCase?)->()) {
        var parser = Parser()
        let terminationTypes: [LineType] = [.testFail, .testPass]
        var result: TestCase?
        for line in sequence {
            result = parser.parse(line)
            guard let type = LineType(rawValue: line) else {
                XCTFail("Unexpected line type found for input: \(line)")
                return
            }
            
            let testEnded = terminationTypes.contains(type)
            if testEnded == false && result != nil {
                XCTAssert(result == nil, "Parser should not generate a TestCase until the test completes. TestCase genereated from: \(line)")
            }
        }
        completion(result)
    }
    
}

class TestCaseSpec: XCTestCase {
    
}
