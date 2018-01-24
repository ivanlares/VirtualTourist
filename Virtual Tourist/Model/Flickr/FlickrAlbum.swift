//
//  FlickrAlbum.swift
//  Virtual Tourist
//
//  Created by ivan lares on 1/26/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import Foundation

/// Model representing a flickr album.
/// To be used along side CoreData objects.
/// Created to be used in instances where we don't need coredata.
struct FlickrAlbum {
    
    var photos: [FlickrPhoto] = [FlickrPhoto]()
    var page:Int = 0
    
    init(photos: [FlickrPhoto], page: Int){
        self.photos = photos
        self.page = page
    }
    
    init(page: Int){
        self.page = page
    }
    
    init(){}
}
