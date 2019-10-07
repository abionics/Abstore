//
//  Infile+CoreDataClass.swift
//  Abstore
//
//  Created by Abionics on 8/16/19.
//  Copyright © 2019 Abionics. All rights reserved.
//
//

import UIKit
import Foundation
import CoreData
import Photos


public class Infile: NSManagedObject {
    var preview: PreviewImage!
    var asset: PHAsset!
    
    var creationDate: Date {
        get { return Infile.intToDate(creationDateRV) }
        set { creationDateRV = Infile.dateToInt(newValue) }
    }
    var modificationDate: Date {
        get { return Infile.intToDate(modificationDateRV) }
        set { modificationDateRV = Infile.dateToInt(newValue) }
    }
    
    convenience init(name: String, preview: PreviewImage, asset: PHAsset, tags: Set<Tag>) {
        print("[CoreData][Info] Add image \(name) to database")
        let context = CoreDataManager.context
        let entity = NSEntityDescription.entity(forEntityName: "Infile", in: context)
        self.init(entity: entity!, insertInto: context)
        
        self.name = name
        self.creationDate = asset.creationDate!
        self.modificationDate = asset.modificationDate!
        self.tags = tags as NSSet
        self.preview = preview
        self.asset = asset
    }
    
    func contains(tag: Tag) -> Bool {
        return tags.contains(tag)
    }
    
    func getTags() -> Set<Tag> {
        return tags as! Set<Tag>
    }
    
    func delete() {
        print("[CoreData][Info] Remove image \(name) from database")
        CoreDataManager.context.delete(self)
    }
    
    private static func dateToInt(_ value: Date) -> Int64 {
        let timeInterval = value.timeIntervalSince1970 * 1000.0
        return Int64(timeInterval)
    }
    
    private static func intToDate(_ value: Int64) -> Date {
        let timeInterval = Double(value)
        return Date(timeIntervalSince1970: timeInterval / 1000.0)
    }
}
