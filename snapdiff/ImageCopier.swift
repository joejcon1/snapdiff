//
//  FileManager.swift
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation

struct ImageCopier {
    func copyImages(forFailures testCaseFailures: [SnapshotTestFailure?], withConfiguration config: Configuration) {
        
        for failure in testCaseFailures {
            guard let failure = failure else { continue }
            copyFile(src: failure.failureImagePath, withConfiguration: config)
            copyFile(src: failure.referenceImagePath, withConfiguration: config)
        }
    }

    func copyFile(src: String?, withConfiguration config: Configuration) {
        guard let src = src else { return }
        guard let fn = src.components(separatedBy: "/").last else { return }
        let dst = config.imageDirectory.path + "/" + fn
        let srcURL = URL(fileURLWithPath: src)
        let dstURL = URL(fileURLWithPath: dst)
        do {
            Logger.debug("\n\n\ncopying from \n\(srcURL.absoluteString) to \n\(dstURL.absoluteString)")
            try FileManager.default.copyItem(at: srcURL, to: dstURL)
        } catch let error as NSError {
            let acceptableErrorCodes = [NSFileWriteFileExistsError]
            if acceptableErrorCodes.contains(error.code) {
                return
            }
            Logger.stderr("Error copying file for \(src) \(error.localizedDescription)")
        }
    }
}
