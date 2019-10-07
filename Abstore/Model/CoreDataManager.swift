//
//  CoreDataManager.swift
//  Abstore
//
//  Created by Abionics on 8/16/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import CoreData

class CoreDataManager {
    private init() {}
    
    static let instance = CoreDataManager()
    static var context: NSManagedObjectContext { return instance.persistentContainer.viewContext }
    static func save() { instance.save() }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Abstore")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[CoreDataManager][Error] UNRESOLVED ERROR \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("[CoreDataManager][Info] CoreData saved")
            } catch {
                let nserror = error as NSError
                fatalError("[CoreDataManager][Error] UNRESOLVED ERROR \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
