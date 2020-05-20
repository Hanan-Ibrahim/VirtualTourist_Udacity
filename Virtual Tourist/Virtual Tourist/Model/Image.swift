//
//  Image.swift
//  Virtual Tourist
//
//  Created by Hanoudi on 5/18/20.
//  Copyright © 2020 Hanan. All rights reserved.
//

import Foundation
import CoreData

public class Image: NSManagedObject {
    
    convenience init(index:Int, imageURL: String, imageData: NSData?, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entity(forEntityName: "Image", in: context) {

            self.init(entity: entity, insertInto: context)
            self.index = Int16(index)
            self.imageURL = imageURL
            self.imageData = imageData
        } else {
            fatalError("Can't find image")
        }
    }
}

// ------------------------------------------------------------------------ //

extension Image {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Image> {
        return NSFetchRequest<Image>(entityName: "Image")
    }
    
    @NSManaged public var imageData: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var index: Int16
    @NSManaged public var pin: Pin?
    
}
