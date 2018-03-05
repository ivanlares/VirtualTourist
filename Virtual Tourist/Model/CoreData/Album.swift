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
    /// default value is 0
    @NSManaged public var page: Int32
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, location: CLLocationCoordinate2D) {
        
        self.init(entity: entity, insertInto: context)
        self.latitude = String(location.latitude)
        self.longitude = String(location.longitude)
        self.page = 0
    }
    
    convenience init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?, location: CLLocationCoordinate2D, page: Int32) {
        
        self.init(entity: entity, insertInto: context)
        self.latitude = String(location.latitude)
        self.longitude = String(location.longitude)
        self.page = page
    }
    
}

// MARK: - Helper

extension Album{
    
    /// true if photos are empty 
    var isEmpty: Bool{
        
        guard let photos = photos else{
            return false
        }
        
        return photos.count <= 0
    }
    
    /// removes all photos from the managed object context
    /// associated with `self`
    func removeAllPhotos(){
        
        guard let photos = photos else {
            return
        }
        
        for photo in photos{
            managedObjectContext?.delete(photo as! NSManagedObject)
        }
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
