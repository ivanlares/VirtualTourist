//
//  Photo+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by ivan lares on 2/5/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Photo)
public class Photo: NSManagedObject {
    
    @NSManaged public var urlString: String?
    @NSManaged public var textDescription: String?
    @NSManaged public var photo: NSData?
    @NSManaged public var album: Album?
    
}

extension Photo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }
    
    class func photo(fromFlickrPhoto flickrPhoto: FlickrPhoto, inContext context: NSManagedObjectContext?) -> Photo{
        
        let photo = Photo(entity: Photo.entity(), insertInto: context)
        photo.urlString = flickrPhoto.urlString
        photo.textDescription = flickrPhoto.title
        
        return photo
    }
    
}
