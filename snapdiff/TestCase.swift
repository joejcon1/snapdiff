//
//  TestCase
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation

typealias TestImageNames = (reference: String, failure: String)

struct TestCase {
    let name: String
    var snapshotTestFailures = [SnapshotTestFailure] ()

    var passed: Bool = false

    init(name: String) {
        self.name = name
    }

    func hasSnapshotFailures() -> Bool {
        return snapshotTestFailures.count > 0
    }
}

struct SnapshotTestFailure {
    var referenceImagePath: String
    var failureImagePath: String
    var referenceImageFileName: String?
    var failureImageFileName: String?


    init(filenames: TestImageNames) {
        referenceImagePath = filenames.reference
        failureImagePath = filenames.failure
        
        let referenceComponents = referenceImagePath.components(separatedBy: "/")
        referenceImageFileName = referenceComponents.last
        
        let failureComponents = failureImagePath.components(separatedBy: "/")
        failureImageFileName = failureComponents.last

        
    }
}
