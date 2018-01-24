//
//  PlistHelper.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/23/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

class PlistHelper{
    
    private init() {}
    
    static func getPlist(withName name: String) -> NSDictionary?{
        
        var plistDictionary: NSDictionary?
        if let path = Bundle.main.path(forResource: name, ofType: "plist") {
            plistDictionary = NSDictionary(contentsOfFile: path)
        }
        
        return plistDictionary
    }
}
