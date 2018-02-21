//
//  Album+CoreDataClass.swift
//  Virtual Tourist
//
//  Created by ivan lares on 2/5/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//
//

import CoreLocation
import CoreData

@objc(Album)
public class Album: NSManagedObject {
    
    @NSManaged public var longitude: String?
    @NSManaged public var latitude: String?
    @NSManaged public var photos: NSOrderedSet?
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, location: CLLocationCoordinate2D) {
        
        self.init(entity: entity, insertInto: context)
        self.latitude = String(location.latitude)
        self.longitude = String(location.longitude)
    }
    
}

// MARK: - Helper

extension Album{
    
    /// true if photos is not empty 
    var isEmpty: Bool{
        
        guard let photos = photos else{
            return false
        }
        
        return photos.count > 0
    }
    
}

// MARK: - Fetch Request

extension Album {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Album> {
        return NSFetchRequest<Album>(entityName: "Album")
    }
    
}

// MARK: Generated accessors for photos

extension Album {
    
    @objc(insertObject:inPhotosAtIndex:)
    @NSManaged public func insertIntoPhotos(_ value: Photo, at idx: Int)
    
    @objc(removeObjectFromPhotosAtIndex:)
    @NSManaged public func removeFromPhotos(at idx: Int)
    
    @objc(insertPhotos:atIndexes:)
    @NSManaged public func insertIntoPhotos(_ values: [Photo], at indexes: NSIndexSet)
    
    @objc(removePhotosAtIndexes:)
    @NSManaged public func removeFromPhotos(at indexes: NSIndexSet)
    
    @objc(replaceObjectInPhotosAtIndex:withObject:)
    @NSManaged public func replacePhotos(at idx: Int, with value: Photo)
    
    @objc(replacePhotosAtIndexes:withPhotos:)
    @NSManaged public func replacePhotos(at indexes: NSIndexSet, with values: [Photo])
    
    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)
    
    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)
    
    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSOrderedSet)
    
    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSOrderedSet)
    
}
