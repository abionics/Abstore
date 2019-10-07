//
//  Storage.swift
//  Abstore
//
//  Created by Abionics on 8/15/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit
import CoreData

class Storage {
    static let instance = Storage()
    
    let infiles = InfilesKeeper()
    let tags = TagsKeeper()
    var basetag: Tag!
    var untagged: Tag!
    
    var defaultSearchExpression: String!
    let parser = Parser()
    
    private init() {
        let timer = SimpleTimer()
        
        initTags()
        initInfiles()
        fit()
        loadSettings()
        CoreDataManager.save()
        
        print("[Main][Info] Storage successful initalized in \(timer.stime())")
        tags.info()
        infiles.info()
    }
    
    func initTags() {
        let context = CoreDataManager.context
        let request = NSFetchRequest<Tag>(entityName: "Tag")
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let tagsDB = try! context.fetch(request)
        
        print("[Main][Info] Tags: \(tagsDB.count)")
        
        for tag in tagsDB {
            if (tag.infiles.count > 0) {
                tags.add(tag)
            } else {
                tag.delete()
            }
        }
        
        basetag = try! tags.getOrCreate(name: "***Basetag***", color: UIColor.black)
        untagged = try! tags.getOrCreate(name: "***Untagged***", color: UIColor.black)
    }
    
    func initInfiles() {
        let timer = SimpleTimer()
        
        //database (Core Data)
        timer.start()
        let context = CoreDataManager.context
        let request = NSFetchRequest<Infile>(entityName: "Infile")
        request.sortDescriptors = [NSSortDescriptor(key: "creationDateRV", ascending: false)]
        let infilesDB = try! context.fetch(request)
        print("[Main][Info] Loaded images from Core Data in \(timer.stime())")
        
        //device (Gallery)
        timer.start()
        let gallery = GalleryLoader()
        var images = gallery.load()
        print("[Main][Info] Loaded images from Gallery in \(timer.stime())")
        
        print("[Main][Info] Images in database: \(infilesDB.count)")
        print("[Main][Info] Images in device:   \(images.count)")
        
        //set image to exist infiles
        //delete infiles that is not exist
        for infile in infilesDB {
            if let image = images[infile.name] {
                infile.preview = image.preview
                infile.asset = image.asset
                infiles.add(infile)
                images.removeValue(forKey: infile.name)
            } else {
                infile.delete()
            }
        }
        
        //create infile from new image
        for image in images {
            let infile = Infile(name: image.key, preview: image.value.preview, asset: image.value.asset, tags: [basetag, untagged])
            infiles.add(infile)
        }
    }
    
    func fit() {
        tags.fit()
    }
    
    func loadSettings() {
        defaultSearchExpression = basetag.name
    }
    
    func search(expression: String) -> [Infile] {
        let timer = SimpleTimer()
        
        var expression = expression.trimmingCharacters(in: .whitespacesAndNewlines)
        if (expression.isEmpty) {
            expression = defaultSearchExpression
        }
        
        do {
            let result = try parser.parse(expression: expression, tags: tags)
            defer { print("[Main][Info] Search of \"\(expression)\" completed in \(timer.stime()), found \(result.count) infiles") }
            return result.sorted { $0.creationDate < $1.creationDate }
        } catch let error as ParserError {
            print("[Main][Warning] Search parse exception: \(error.localizedDescription)")
            ViewController.instance?.alert(title: "Search parse exception", message: error.localizedDescription)
            return []
        } catch {
            print("[Main][Error] SEARCH UNKNOWN ERROR")
            return []
        }
    }
    
    @discardableResult func addTag(infile: Infile, tag: String) -> Bool {
        print("[Main][Info] Try to add tag \"\(tag)\" to infile \(infile.name)")
        return safeTagAction(action: {
            let tag = try tags.getOrCreate(name: tag)
            if infile.contains(tag: tag) {
                print("[Main][Info] Infile has already had this tag")
                return
            }
            infile.addToTags(tag)
            if infile.tags.count > 2 && infile.contains(tag: untagged) {
                infile.removeFromTags(untagged)
            }
        })
    }
    
    @discardableResult func removeTag(infile: Infile, tag: Tag) -> Bool {
        print("[Main][Info] Try to remove tag \"\(tag.name)\" from infile \(infile.name)")
        if !infile.contains(tag: tag) {
            print("[Main][Info] It does not have this tag")
            return false
        }
        infile.removeFromTags(tag)
        if infile.tags.count == 1 && !infile.contains(tag: untagged) {
            infile.addToTags(untagged)
        }
        fit() //if tag dont have more infiles - remove it
        CoreDataManager.save()
        return true
    }
    
    @discardableResult func addAlias(tag: Tag, alias: String) -> Bool {
        print("[Main][Info] Try to add alias \"\(alias)\" to tag \(tag.name)")
        return safeTagAction(action: { try tags.addAlias(tag: tag, alias: alias) })
    }
    
    @discardableResult func removeAlias(tag: Tag, alias: String) -> Bool {
        print("[Main][Info] Try to remove alias \"\(alias)\" from tag \(tag.name)")
        if !tag.contains(alias: alias) {
            print("[Main][Info] It does not have this alias")
            return false
        }
        tags.removeAlias(tag: tag, alias: alias)
        CoreDataManager.save()
        return true
    }
    
    @discardableResult func changeTagName(tag: Tag, name: String) -> Bool {
        print("[Main][Info] Try to change name of \"\(tag.name)\" to \(name)")
        return safeTagAction(action: { try tags.changeName(tag: tag, name: name) })
    }
    
    func changeTagColor(tag: Tag, color: UIColor) {
        print("[Main][Info] Change color of \"\(tag.name)\" to \(color.ahsv())")
        tag.color = color
        CoreDataManager.save()
    }
    
    func safeTagAction(action: () throws -> Void) -> Bool {
        do {
            try action()
            CoreDataManager.save()
            return true
        } catch TagError.emptyName {
            //skip, just dont create tag with empty name
        } catch TagError.reservedName {
            print("[Main][Warning] Invalid tag name: this name is already used")
            ViewController.instance?.alert(title: "Invalid tag name", message: "This name is already used")
        } catch TagError.reservedCharacter(let character) {
            print("[Main][Warning] Invalid tag name: tag name includes reserved operator \"" + character + "\", remove it")
            ViewController.instance?.alert(title: "Invalid tag name", message: "Tag name includes reserved operator \"" + character + "\", remove it")
        } catch {
            print("[Main][Error] ADD TAG UNKNOWN ERROR")
        }
        return false
    }
}
