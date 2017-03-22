//
//  TOError.swift
//  TVOSOAuth
//
//  Created by Rabah Shihab on 3/12/17.
//  Copyright © 2017 BitHunch LLC. All rights reserved.
//

import Foundation

public enum TOError: Error {
    case request(statusCode: Int, message: String)
    case serialization(message: String)
    case network(message: String)
    case server(message: String)
    case timeout(message: String)
    
    public var message: String {
        switch self {
        case .request(let status, let message):
            return message
        case .serialization(let message):
            return message
        case .network(let message):
            return message
        case .server(let message):
            return message
        case .timeout(let message):
            return message
        }
    }

}
