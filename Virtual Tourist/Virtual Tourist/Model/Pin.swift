//
//  Pin.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/18/20.
//  Copyright © 2020 Hanan. All rights reserved.
//

import Foundation
import CoreData

public class Pin: NSManagedObject {
    
    convenience init(latitude: Double, longitude: Double, context: NSManagedObjectContext) {
        
        if let ent = NSEntityDescription.entity(forEntityName: "Pin", in: context) {
            
            self.init(entity: ent, insertInto: context)
            self.latitude   = latitude
            self.longitude  = longitude
            
        } else {
            
            fatalError("Unable To Find Entity Name!")
        }
    }
    
}

// ------------------------------------------------------------------------ //
extension Pin {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin> {
        return NSFetchRequest<Pin>(entityName: "Pin")
    }
    
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photo: NSSet?
    
    @objc(addPhotoObject:)
    @NSManaged public func addToPhoto(_ value: Image)
    
    @objc(removePhotoObject:)
    @NSManaged public func removeFromPhoto(_ value: Image)
    
    @objc(addPhoto:)
    @NSManaged public func addToPhoto(_ values: NSSet)
    
    @objc(removePhoto:)
    @NSManaged public func removeFromPhoto(_ values: NSSet)
}
