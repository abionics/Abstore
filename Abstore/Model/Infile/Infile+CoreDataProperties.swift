//
//  Infile+CoreDataProperties.swift
//  Abstore
//
//  Created by Abionics on 8/16/19.
//  Copyright © 2019 Abionics. All rights reserved.
//
//

import Foundation
import CoreData


extension Infile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Infile> {
        return NSFetchRequest<Infile>(entityName: "Infile")
    }

    @NSManaged public var name: String
    @NSManaged public var creationDateRV: Int64
    @NSManaged public var modificationDateRV: Int64
    @NSManaged public var tags: NSSet

}

// MARK: Generated accessors for tags
extension Infile {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: Tag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: Tag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}
