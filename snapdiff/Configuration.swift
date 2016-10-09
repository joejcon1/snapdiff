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
        FileManager.default.createDirectoryIfNeeded(url: url)
        return url
    }
    
    var imageDirectory: URL {
        let dir = outputDirectory.appendingPathComponent(imageDirectoryName, isDirectory: true)
        FileManager.default.createDirectoryIfNeeded(url: dir)
        return dir
    }
    
    var assetsDirectory: URL {
        let dir = outputDirectory.appendingPathComponent(assetsDirectoryName, isDirectory: true)
        FileManager.default.createDirectoryIfNeeded(url: dir)
        return dir
    }
    
    var htmlOutputFile: URL {
        return URL(fileURLWithPath: fileName + ".html", isDirectory: false, relativeTo: outputDirectory)
    }
    
    init?(withParameters params: ParameterList) {
        
        // --help
        if params.flag(.help) {
            Logger.stdout("\(ParameterParser.usage())")
            exit(EXIT_SUCCESS)
        }
        
        // --color
        if params.flag(.color) {
            Logger.colorMode = true
        }
        
        // --debug
        if params.flag(.debug) {
            Logger.debugMode = true
        }
        
        // --output-dir
        let directoryArg = params.argument(.directory)

        if let directoryArgValue = directoryArg {
            baseDirectory = URL(fileURLWithPath: directoryArgValue, isDirectory: true)
        } else {
            baseDirectory = URL(fileURLWithPath: Option.directory.defaultValue())
        }
        
        // --output-file
        var fn = Option.filename.defaultValue()
        let filenameArg = params.argument(.filename)
        if let filenameArgValue = filenameArg {
            fn = filenameArgValue
        }
        
        // --no-timestamp
        if params.flag(.notimestamp) {
            fn += Configuration.dateString()
        }
        fileName = fn
        
        Logger.debug("Started with configuration of \(htmlOutputFile.absoluteString)")
        
    }
    
    static private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd--hh-mm-ss"
        return formatter.string(from: Date())
    }
}


fileprivate extension FileManager {
    fileprivate func createDirectoryIfNeeded(url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) == false else { return }
        do {
            Logger.debug("Creating Dir at \(url.absoluteString)")
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            
        } catch {
            Logger.stderr("Can't create directory \(error)")
        }
    }
}

