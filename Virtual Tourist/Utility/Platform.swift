//
//  DeviceHelper.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/29/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

struct Platform {
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
    
}
