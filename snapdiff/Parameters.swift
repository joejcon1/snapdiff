//
//  Parameters.swift
//  snapdiff
//
//  Created by Joe Conway on 02/10/2016.
//  Copyright © 2016 jc. All rights reserved.
//

import Foundation
struct ParameterParser {
    
    static func parseCurrentParameters() -> ParameterList {
        /*
         Get the list of options from the process
         */
        var parameterStrings = CommandLine.arguments
        
        /*
         Remove the initial parameter, it is just the filename of the script
         */
        parameterStrings.remove(at: 0)
        
        
        /*
         Convert all the paramters into actual Parameter objects
         */
        var params: [Parameter] = []
        for param in parameterStrings {
            if let parsed = Parameter(input: param) {
                params.append(parsed)
            }
        }
        return ParameterList(params: params)
    }
    
    static func usage() -> String {
        let usage = "Usage: \n\tsnapdiff\n\tsnapdiff [--option=argument]\n\tsnapdiff [--flag]\n\tsnapdiff --help"
        let allParameters: [ParameterType] = Option.allValues() + Flag.allValues()
        let allParametersDescriptions = allParameters.map({"--\($0.description)\t:\t\($0.usageDescription)"})
        var optionsString = "Options:"
        for param in allParametersDescriptions {
            optionsString += "\n\t \(param)"
        }
        return "\(usage)\n\(optionsString)"
    }
}

/*
 Represents a parameter provided to the program.
 
 Expects parameters to be provided in the following format:
 snapdiff --flag --option=argument
*/
struct Parameter: CustomStringConvertible {
    let type: ParameterType
    var value: String?
    
    
    init?(input: String) {
        
        let components = input.components(separatedBy: "=")
        var typeName = components[0]
        typeName = typeName.replacingOccurrences(of: "--", with: "")
        guard let type = Option(rawValue: typeName) else {
            Logger.fatal("Unexpected option \(typeName)\n\(ParameterParser.usage())")
        }
        self.type = type
        guard components.count > 1 else {
            return
        }
        value = components[1]
        
    }
    
    var description: String {
        var desc = "\(type)"
        if type is Option {
            guard let value = value else {
                Logger.fatal("A value is required for the option \(type)")
            }
            desc += "= \(value)"
        }
        return desc
    }
}



struct ParameterList {
    var params: [Parameter]
    private func matchingParameters(ofType type: ParameterType) -> [Parameter] {
        return params.filter({ $0.type == type })
    }
    
    func argument(_ type: Option) -> String? {
        return matchingParameters(ofType: type).first?.value
    }
    
    func flag(_ type: Flag) -> Bool {
        return matchingParameters(ofType: type).isEmpty == false
    }
}


