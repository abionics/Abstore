//
//  Tag+CoreDataProperties.swift
//  Abstore
//
//  Created by Abionics on 8/16/19.
//  Copyright © 2019 Abionics. All rights reserved.
//
//

import Foundation
import CoreData


extension Tag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Tag> {
        return NSFetchRequest<Tag>(entityName: "Tag")
    }

    @NSManaged public var name: String
    @NSManaged public var colorRV: Int32
    @NSManaged public var aliasesRV: NSObject
    @NSManaged public var infiles: NSSet

}

// MARK: Generated accessors for infiles
extension Tag {

    @objc(addInfilesObject:)
    @NSManaged public func addToInfiles(_ value: Infile)

    @objc(removeInfilesObject:)
    @NSManaged public func removeFromInfiles(_ value: Infile)

    @objc(addInfiles:)
    @NSManaged public func addToInfiles(_ values: NSSet)

    @objc(removeInfiles:)
    @NSManaged public func removeFromInfiles(_ values: NSSet)

}
