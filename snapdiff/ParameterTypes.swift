//
//  ParameterTypes.swift
//  snapdiff
//
//  Created by Joe Conway on 09/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation

protocol ParameterType: CustomStringConvertible {
    static func allValues() -> [ParameterType]
    var usageDescription: String { get }
}

enum Option: String, ParameterType {
    case directory = "output-dir"
    case filename = "output-file"
    
    var description: String {
        return rawValue + "=<value>"
    }
    
    var usageDescription: String {
        switch self {
        case .directory:
            return "Specify the location of the output directory for generated files. If this directory does not exist, it will be created. Defaults to \"\(Option.directory.defaultValue())\""
        case .filename:
            return "Specify the prefix for the output directory name. Defaults to \"\(Option.filename.defaultValue())\""
        }
    }
    
    func defaultValue() -> String {
        switch self {
        case .directory:
            return "./"
        case .filename:
            return "snapdiff_"
        }
    }
    
    static func allValues() -> [ParameterType] {
        return [Option.directory, Option.filename]
    }
}

enum Flag: String, ParameterType {
    case debug = "debug"
    case color = "color"
    case help = "help"
    case notimestamp = "no-timestamp"
    
    var description: String {
        return rawValue
    }
    
    var usageDescription: String {
        switch self {
        case .debug:
            return "Output debugging information."
        case .color:
            return "Add ANSI colorized output to all log output"
        case .help:
            return "Print usage information"
        case .notimestamp:
            return "Disable output directory timestamp suffix. Useful if you want output to always go to the same directory"
        }
    }
    
    
    static func allValues() -> [ParameterType] {
        return [Flag.debug, Flag.color, Flag.notimestamp]
    }
}

func == (rhs: ParameterType, lhs: ParameterType) -> Bool {
    return rhs.description == lhs.description
}

