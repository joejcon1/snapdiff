//
//  Logger.swift
//  snapdiff
//
//  Created by Joe Conway on 04/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation

let escape = "\u{001B}["
let none   = escape + "0m"
let red    = escape + "0;31m"
let green  = escape + "0;32m"
let yellow = escape + "0;33m"

enum LogLevel {
    case debug
    case stdout
    case stderr
    case fatal
}

let prefix = "snapdiff: "

struct Logger {
    static var debugMode = false
    static var colorMode = false
    
    static func log(_ level: LogLevel, msg: String) {
        let prefixedMsg = prefix + msg
        switch level {
        case .debug:
            guard Logger.debugMode == true else { return }
            if colorMode {
                print("\(green)\(prefixedMsg)")
            } else {
                print(prefixedMsg)
            }
        case .stdout:
            if colorMode {
                print("\(none)\(msg)")
            } else {
                print(msg)
            }
        case .stderr:
            fallthrough
        case .fatal:
            var output: String
            if colorMode {
                output = "\(red)\(prefixedMsg)"
            } else {
                output = prefixedMsg
            }
            
            if let outputData = "\(output)\n".data(using: .utf8) {
                FileHandle.standardError.write(outputData)
            } else {
                print(output)
            }
        }
    }
    
    
    static func debug(_ msg: String) {
        Logger.log(.debug, msg: msg)
    }
    
    static func stdout(_ msg: String) {
        Logger.log(.stdout, msg: msg)
    }
    
    static func stderr(_ msg: String) {
        Logger.log(.stderr, msg: msg)
    }
    
    static func fatal(_ msg: String) -> Never {
        Logger.log(.fatal, msg: msg)
        exit(EXIT_FAILURE)
    }
    
    private static func terminate() -> Never {
        exit(EXIT_FAILURE)
    }
}
