//
//  TOError.swift
//  TVOSOAuth
//
//  Created by Rabah Shihab on 3/12/17.
//  Copyright © 2017 BitHunch LLC. All rights reserved.
//

import Foundation

public enum TOError: Error {
    case network(error: Error)
    case serialization(reason: String)
    case jsonSerialization(error: Error)
    case timeout(reason: String)
}
