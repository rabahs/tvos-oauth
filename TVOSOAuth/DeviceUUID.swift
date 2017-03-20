//
//  Device.swift
//  cloudphotos
//
//  Created by Rabah Shihab on 3/11/16.
//  Copyright © 2016 Bithunch LLC. All rights reserved.
//

import Foundation

struct DeviceUUID {

    static var uuid: String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
}
