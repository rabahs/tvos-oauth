//
//  Utils.swift
//  cloudphotos
//
//  Created by Rabah Shihab on 3/11/16.
//  Copyright © 2016 Bithunch LLC. All rights reserved.
//

import Foundation
import CryptoSwift

class Utils {
    static func signature(_ params: [String: String], secret: String) -> String {
        let sortedParams = params.sorted { $0.0 < $1.0 }
        let s = sortedParams.map({ "\($0.0)&\($0.1)" }).joined(separator: "&") + "&\(secret)"
        return s.sha1()
    }
}
