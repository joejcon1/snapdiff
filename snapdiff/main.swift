//
//  main.swift
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//


import Foundation


// add the destinations to SwiftyBeaver

func main() {
    
    /*
     * Start reading stdin
     */
    var parser = Parser()
    let imageMover = ImageCopier()
    let generator = HTMLGenerator()
    
    let arguments = Argument.parseArguments()
    
    guard let configuration = Configuration(withArguments: arguments) else {
        Logger.fatal("Invalid arguments. \(arguments)")
    }
    
    while let line = readLine() {
        if let failedTest: TestCase = parser.parse(line) {
            imageMover.copyImages(forFailures: failedTest.snapshotTestFailures, withConfiguration: configuration)
        }
        Logger.stdout(line)
    }
    let failedTests = parser.failedSnapshotTestCases()
    Logger.stdout("\(failedTests.count) Failed snapshot tests found")
    
    /*
     * html generator takes list of failed tests, returns html
     */
    generator.generatePage(forFailures: failedTests, withConfiguration: configuration)
    Logger.stdout(configuration.htmlOutputFile.absoluteString)
    exit(EXIT_SUCCESS)
}

main()

