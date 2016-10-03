//
//  Args.swift
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation

struct Argument: CustomStringConvertible {
    let option: Option
    var value: String?
    
    static func parseArguments() -> [Argument] {
        /*
         Get the list of arguments from the process
         */
        var argumentStrings = CommandLine.arguments
        
        /*
         String the initial arg, it is just the filename of the script
         */
        argumentStrings.remove(at: 0)
        
        
        /*
         Convert all the arguments into actual Argument objects
         */
        var arguments: [Argument] = []
        for argument in argumentStrings {
            if let parsed = Argument(input: argument) {
                arguments.append(parsed)
                Logger.debug(parsed.description)
            }
        }
        return arguments
    }
    
    init?(input: String) {
        
        let components = input.components(separatedBy: "=")
        var optionName = components[0]
        optionName = optionName.replacingOccurrences(of: "--", with: "")
        guard let option = Option(rawValue: optionName) else {
            Logger.fatal("Unexpected argument \(optionName)")
        }
        self.option = option
        guard components.count > 1 else {
            return
        }
        value = components[1]
        
    }
    
    var description: String {
        var desc = "\(option.rawValue)"
        if let value = value {
            desc += "= \(value)"
        }
        return desc
    }
}

enum Option: String {
    case directory = "output-dir"
    case filename = "output-file"
    case debug = "debug"
    case color = "color"
}
