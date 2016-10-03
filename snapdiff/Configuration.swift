//
//  Configuration.swift
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation

struct Configuration {
    let baseDirectory: URL
    
    private let fileName: String
    private let imageDirectoryName: String = "images"
    private let assetsDirectoryName: String = "assets"
    
    
    var outputDirectory: URL {
        let url = URL(fileURLWithPath: fileName, relativeTo: baseDirectory)
        createOutputDirIfNeeded(url: url)
        return url
    }
    
    var imageDirectory: URL {
        let dir = outputDirectory.appendingPathComponent(imageDirectoryName, isDirectory: true)
        createOutputDirIfNeeded(url: dir)
        return dir
    }
    
    var assetsDirectory: URL {
        let dir = outputDirectory.appendingPathComponent(assetsDirectoryName, isDirectory: true)
        createOutputDirIfNeeded(url: dir)
        return dir
    }
    
    var htmlOutputFile: URL {
        return URL(fileURLWithPath: fileName + ".html", isDirectory: false, relativeTo: outputDirectory)
    }
    
    init?(withArguments args: [Argument]) {
        
        let colorArg = args.first { $0.option == .color }
        if colorArg != nil {
            Logger.colorMode = true
        }
        
        let debugArg = args.first { $0.option == .debug }
        if debugArg != nil {
            Logger.debugMode = true
            Logger.debug("DEBUGGING MODE ENABLED!!!")
        }
        
        let directoryArg = args.first { $0.option == .directory }
        let filenameArg = args.first { $0.option == .filename }

        if let directoryArgValue = directoryArg?.value {
            baseDirectory = URL(fileURLWithPath: directoryArgValue, isDirectory: true)
        } else {
            baseDirectory = URL(fileURLWithPath: "./")
        }

        if let filenameArgValue = filenameArg?.value {
            fileName = filenameArgValue + "_failed_snapshots_" + Configuration.dateString()
        } else {
            fileName = "snapdiff_" + Configuration.dateString()
        }

        Logger.debug("Started with configuration of \(htmlOutputFile.absoluteString)")
        
    }
    
    static private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd--hh-mm-ss"
        return formatter.string(from: Date())
    }
    
    
    private func createOutputDirIfNeeded(url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) == false else { return }
        do {
            Logger.debug("Creating Dir at \(url.absoluteString)")
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            Logger.stderr("Can't create directory \(error)")
        }
    }

}
