//
//  Tag+CoreDataClass.swift
//  Abstore
//
//  Created by Abionics on 8/16/19.
//  Copyright © 2019 Abionics. All rights reserved.
//
//

import UIKit
import Foundation
import CoreData


public class Tag: NSManagedObject {
    var color: UIColor {
        get { return Tag.intToColor(colorRV) }
        set { colorRV = Tag.colorToInt(newValue) }
    }
    var aliases: [String] {
        get { return (aliasesRV as! [String]).sorted() }
    }
    
    convenience init(name: String, color: UIColor, protected: Bool) {
        print("[CoreData][Info] Add tag \"\(name)\" to database")
        let context = CoreDataManager.context
        let entity = NSEntityDescription.entity(forEntityName: "Tag", in: context)
        self.init(entity: entity!, insertInto: context)
        
        self.name = name
        self.color = color
        self.protected = protected
        self.aliasesRV = [] as NSObject
        self.infiles = []
    }
    
    func contains(alias: String) -> Bool {
        return aliases.contains(alias)
    }
    
    //dont forget to save CoreDataManager
    func add(alias: String) {
        print("[CoreData][Info] Add alias \"\(alias)\" to \"\(name)\"")
        var newAliases = aliases;
        newAliases.append(alias)
        aliasesRV = newAliases as NSObject
    }
    
    //dont forget to save CoreDataManager
    func remove(alias: String) {
        print("[CoreData][Info] Remove alias \"\(alias)\" from \"\(name)\"")
        var newAliases = aliases;
        newAliases.remove(object: alias as AnyObject)
        aliasesRV = newAliases as NSObject
    }
    
    func delete() {
        print("[CoreData][Info] Remove tag \"\(name)\" from database")
        CoreDataManager.context.delete(self)
    }
    
    private static func colorToInt(_ value: UIColor) -> Int32 {
        let color = CIColor(color: value)
        let red = UInt(color.red * 255 + 0.5)
        let green = UInt(color.green * 255 + 0.5)
        let blue = UInt(color.blue * 255 + 0.5)
        return Int32((red << 16) | (green << 8) | blue)
    }
    
    private static func intToColor(_ value: Int32) -> UIColor {
        let red = CGFloat((value & 0xff0000) >> 16) / 0xff
        let green = CGFloat((value & 0x00ff00) >> 8) / 0xff
        let blue = CGFloat(value & 0x0000ff) / 0xff
        let alpha = CGFloat(1.0)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
