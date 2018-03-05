//
//  CoreDataStack.swift
//  Virtual Tourist
//
//  Created by ivan lares on 2/5/18.
//  Copyright © 2018 ivan lares. All rights reserved.
//

import CoreData

public class CoreDataStack {
    
    let modelName:String
    
    init(modelName: String){
        
        self.modelName = modelName
    }
    
    /// Context uses a private queue.
    /// This context is hooked up the the persistentStoreCoordinator.
    /// Persisting to disk on a background context is done for performance reasons.
    /// This context is meant to be used internally.
    private lazy var persitingContext: NSManagedObjectContext = {
        
        var privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        return privateContext
    }()
    
    /// Context that uses the main queue.
    // Should be used to update the UI and persists small to medium changes.
    lazy var mainContext: NSManagedObjectContext = {
        
        var managedObjectContext =
            NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = self.persitingContext
        
        return managedObjectContext
    }()
    
    /// New background context.
    /// Child of mainContext.
    func newBackgroundContext() -> NSManagedObjectContext {
        
        let backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundContext.parent = mainContext

        return backgroundContext
    }
    
    /// Block is performed on a new background context.
    /// The context is private and a child of the Main Context.
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void){
        
        let backgroundContext = newBackgroundContext()
        block(backgroundContext)
    }
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel:self.managedObjectModel)
        let url =
            self.applicationDocumentsDirectory.appendingPathComponent(self.modelName + ".sqlite")
        do {
            let options =
                [NSMigratePersistentStoresAutomaticallyOption:true]
            try coordinator.addPersistentStore(
                ofType: NSSQLiteStoreType, configurationName:nil, at:url,
                options:options)
        } catch  {
            print("Error adding persistent store.")
        }
        
        return coordinator
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        
        let modelURL =
            Bundle.main.url(forResource: self.modelName, withExtension:"momd")!
        
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    /// Persists changes in the main context to disk
    func saveContext() {
        
        mainContext.performAndWait { () -> Void in
            if mainContext.hasChanges {
                do {
                    try mainContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        persitingContext.perform(){ () -> Void in
            if self.persitingContext.hasChanges {
                do {
                    try self.persitingContext.save()
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helper
    
    private lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask)
        
        return urls[0]
    }()
    
}
