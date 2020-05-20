//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/19/20.
//  Copyright © 2020 Hanan. All rights reserved.
//
//  This is the controller responsible for on-disk persistence.
//  This is the Core Data Model Controller.
//  This will be used to define a database schema,
//  Create a database file, and create and manage record data.
//  The default database that Core Data works with is the SQLite database


import Foundation
import CoreData

//  MARK:- Data Controller
struct DataController {
    
    // MARK:- Components
    // NSManagedObject represents a single obj stored in Core Data (entity)
    // NSPersistentStoreCoordinator has a ref to the managed object model,
    // that describes the entites (similar to classes) in the store it manages
    // it is the central object of the Core Data Stack
    // modelURL holds URL to the model from main bundle
    // databaseURL holds URL to the database (SQLite)
    // context for saving and retrieving data from dataStore (i.e 'scratch Pad')
    
    private let model: NSManagedObjectModel
    private let modelURL: URL
    let persistentStoreCoordinator: NSPersistentStoreCoordinator
    let databaseURL: URL
    let context: NSManagedObjectContext
    
    // MARK:- Initializer
    init?(modelName: String) {
        // MARK:- get modelURL
        // try to get URL to model else return
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd")
            else {
            print("Can't locate \(modelName).self in the main bundle.")
            return nil
        }
        // successfully returned URL to model, set it in modelURL
        self.modelURL = modelURL
        
        // MARK:- Make model
        guard let model = NSManagedObjectModel(contentsOf: modelURL)
            else {
            print("Can't create a model from \(modelURL)")
            return nil
        }
        // successfully made model
        self.model = model

        // MARK:- Create persistent store coordinator
        persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // MARK:- Create context
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = persistentStoreCoordinator

        // get a reference to file manager
        let fileManager = FileManager.default
        
        // get document directory path
        guard let documentDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
            else {
            print("Can't reach document directory.")
            return nil
        }
        
        // set path to SQLite database
        self.databaseURL = documentDirectoryURL.appendingPathComponent("VirtualTourist.sqlite")
       
        // set options
        let options = [NSInferMappingModelAutomaticallyOption: true,
                       NSMigratePersistentStoresAutomaticallyOption: true]
        
        // attach SQLite store
        do {
            try attachStore(NSSQLiteStoreType, configuration: nil, URLToStore: databaseURL, options: options as [NSObject : AnyObject]?)
        } catch {
            print("Can't add store to: \(databaseURL)")
        }
    }
    
}

//  MARK:- DataController's Extension

extension DataController  {
    // MARK:- Methods Store, save, auto-save & destroy
    
    func attachStore(_ storeType: String, configuration: String?, URLToStore: URL, options : [NSObject:AnyObject]?) throws {
        
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: databaseURL, options: nil)
    }
        
    func saveContext() throws {
        
        if context.hasChanges {
            try context.save()
        }
    }
    
    func autoSave(_ seconds : Int) {
        
        if seconds > 0 {
            do {
                try saveContext()
                print("Autosaving")
                
            } catch {
                print("Error while trying to autosave.")
            }
            
            let nanoSeconds = UInt64(seconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(nanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time) {
                self.autoSave(seconds)
            }
        }
    }

    func destroyData() throws {
        
        try persistentStoreCoordinator.destroyPersistentStore(at: databaseURL, ofType:NSSQLiteStoreType , options: nil)
        try attachStore(NSSQLiteStoreType, configuration: nil, URLToStore: databaseURL, options: nil)
    }

}
