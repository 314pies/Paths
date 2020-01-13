//
//  Location+CoreDataProperties.swift
//  
//
//  Created by Ian Chen on 2020/1/13.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var content: String?
    @NSManaged public var title: String?

}
