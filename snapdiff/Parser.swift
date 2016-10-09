//
//  Parser.swift
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation


enum LineType: CustomStringConvertible {
    case testStart
    case testFail
    case testPass
    case diff
    
    init?(rawValue: String) {
        let isTestCase = rawValue.contains("Test Case")
        let isStart = isTestCase && rawValue.contains("started")
        let isFail = isTestCase && rawValue.contains("failed")
        let isPass = isTestCase && rawValue.contains("passed")
        let isDiffCommand = rawValue.contains("ksdiff")
        
        if isStart {
            self = .testStart
        } else if isPass {
            self = .testPass
        } else if isFail {
            self = .testFail
        } else if isDiffCommand {
            self = .diff
        } else {
            return nil
        }
    }
    
    var description: String {
        switch self {
        case .testStart:
            return "Start"
        case .testPass:
            return "Pass"
        case .testFail:
            return "Fail"
        case .diff:
            return "diff"
        }
    }
}

struct Parser {
    private var tests: [TestCase] = []
    private var currentTest: TestCase?
    
    mutating func parse(_ line: String) -> TestCase? {
        guard let type = LineType(rawValue: line) else {
            return nil
        }
        switch type {
        case .testStart:
            let parsed = parseTestStart(line: line)
            let test = TestCase(name: parsed)
            currentTest = test
            
        case .testPass:
            return closeTest(success: true)
            
        case .testFail:
            return closeTest(success: false)
            
        case .diff:
            let parsed = parseDiff(line: line)
            let failure = SnapshotTestFailure(filenames: parsed)
            currentTest?.snapshotTestFailures.append(failure)
        }
        return nil
    }
    
    private mutating func closeTest(success: Bool) -> TestCase? {
        currentTest?.passed = success
        guard let test = currentTest else { return nil }
        tests.append(test)
        
        currentTest = nil
        return test
    }
    
    //Test Case '-[SomeTests testAThing]' started.
    private func parseTestStart(line: String) -> String {
        var name = line.replacingOccurrences(of:"Test Case '-[", with:"")
        name = name.replacingOccurrences(of: "]' started", with:"")
        
        return name
    }
    
    //ksdiff "reference@2x.png" "failed@2x.png"
    private func parseDiff(line: String) -> TestImageNames {
        let components = line.components(separatedBy: "\"")
        let reference = components[1]
        let failure = components[3]
        return (reference, failure)
    }
    
    func summary() {
        let passed = tests.filter({ $0.passed == true }).count
        let failed = tests.filter({ $0.passed == false }).count
        Logger.debug("\(passed) passed and \(failed) failed")
    }
    
    func failedTestCases() -> [TestCase] {
        return tests.filter { $0.passed == false}
    }
    
    func failedSnapshotTestCases() -> [TestCase] {
        return failedTestCases().filter { $0.hasSnapshotFailures()}
    }
    
    
}
