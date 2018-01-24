//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/25/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

/// Model representing a flickr photo.
/// To be used along side CoreData objects.
/// Created to be used in instances where we don't need coredata.
struct FlickrPhoto{
    
    let urlString: String
    let title: String
}
