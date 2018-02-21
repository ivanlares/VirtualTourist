//
//  UIHelper.swift
//  Virtual Tourist
//
//  Created by ivan lares on 2/20/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import UIKit

class DeviceHelper {
    
    static var isPad: Bool {
        return (UIScreen.main.traitCollection.userInterfaceIdiom == .pad)
    }
    
}
