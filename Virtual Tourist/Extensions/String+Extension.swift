//
//  String+Extension.swift
//  Virtual Tourist
//
//  Created by ivan lares on 2/10/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

extension String {
    
    func toDouble() -> Double? {
        
        return NumberFormatter().number(from: self)?.doubleValue
    }
}
