//
//  NetworkingError.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/27/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

enum NetworkingError: Error{
    case parsingError
    case unexpectedData
    case unableToRetrieveData
    case customError(String)
}

extension NetworkingError: LocalizedError{
    
    var errorDescription: String?{
        get{
            switch self{
            case .parsingError: return "Unable to parse data."
            case .unexpectedData: return "Unexpected data."
            case .unableToRetrieveData: return "Unable to retrieve data."
            case .customError(let message): return message
            }
        }
    }
}
