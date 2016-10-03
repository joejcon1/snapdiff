//
//  HTMLGenerator.swift
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation

enum TemplateType: String {
    case main = "main_html_template"
    case testDiv = "test_div_template"
}

enum TemplateTag: String {
    case fileTitle = "FILE_TITLE"
    case tests = "TESTS"
    case testTitle = "TEST_TITLE"
    case testSubtitle = "TEST_SUBTITLE"
    case testReferenceImageName = "REFERENCE_IMAGE_FILENAME"
    case testFailureImageName = "FAILURE_IMAGE_FILENAME"
}

struct HTMLGenerator {
    let defaultImage = "default.png"
    func generatePage(forFailures failingTests: [TestCase], withConfiguration configuration: Configuration) {
        copyStyle(withConfiguration: configuration)
        
        var testContent: String = ""
        
        for test in failingTests {
            for failure in test.snapshotTestFailures {
                guard let div = divForTestFailure(test: test, failure: failure) else { continue }
                testContent += div
            }
        }
        
        guard let html = htmlContent(withTests: testContent) else {
            Logger.stderr("Failed to generate HTML for test output")
            return
        }
        writeToDisk(htmlString: html, destination: configuration.htmlOutputFile)
    }
    
    
    private func divForTestFailure(test: TestCase, failure: SnapshotTestFailure) -> String? {
        let reference = failure.referenceImageFileName ?? defaultImage
        let failure = failure.failureImageFileName ?? defaultImage
        
        let testNameComponents = test.name.components(separatedBy: " ")
        let testTitle = testNameComponents[0]
        let testSubtitle = testNameComponents[1]

        let params: [TemplateTag : String] = [
            .testTitle : testTitle,
            .testSubtitle: testSubtitle,
            .testReferenceImageName : reference,
            .testFailureImageName : failure
        ]
        return parseTemplate(type: .testDiv, apply: params)
    }
    
    func htmlContent(withTests tests: String) -> String? {
        let params: [TemplateTag : String] = [
            .fileTitle : "Title",
            .tests: tests
        ]
        return parseTemplate(type: .main, apply: params)
    }
    
    func parseTemplate(type: TemplateType, apply params: [TemplateTag : String]) -> String? {
        var template: String = ""
        switch type {
        case .main:
            template = __generated_var_html_template
        case .testDiv:
            template = __generated_var_div_template
        }
        for (key, value) in params {
            template = template.replacingOccurrences(of: "#" + key.rawValue, with: value)
        }
        return template

    }
}


fileprivate typealias FileWriter = HTMLGenerator
fileprivate extension FileWriter {
    fileprivate func writeToDisk(htmlString: String, destination: URL) {
        do {
            try htmlString.write(to: destination, atomically: false, encoding: .utf8)
        } catch {
            Logger.stderr("Error writing HTML to disk. \(error)")
        }
    }
}

fileprivate typealias StyleGenerator = HTMLGenerator
fileprivate extension StyleGenerator {
    
    fileprivate func copyStyle(withConfiguration configuration: Configuration) {

        let dst = configuration.assetsDirectory.appendingPathComponent("style.css")
        do {
            Logger.debug("\n\n\nwriting css to \n\(dst)")
            try __generated_var_css.write(to: dst, atomically: true, encoding: .utf8)

        } catch {
            Logger.stderr("Error writing css file \(error.localizedDescription)")
        }
    }

}
