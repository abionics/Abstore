//
//  TagsKeeper.swift
//  Abstore
//
//  Created by Abionics on 8/15/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class TagsKeeper {
    private var list = [String: Tag]()
    private let reserved = Parser.reserved
    
    func add(_ tag: Tag) {
        list[tag.name] = tag
        for alias in tag.aliasesRV as! [String] {
            list[alias] = tag
        }
    }
    
    private func create(name: String, color: UIColor, protected: Bool) throws -> Tag {
        let name = try normalizeAndCheckName(name: name)
        let tag = Tag(name: name, color: color, protected: protected)
        add(tag)
        return tag
    }
    
    func getOrCreate(name: String, color: UIColor = Constants.DEFAULT_COLOR, protected: Bool = false) throws -> Tag {
        return try list[name] ?? create(name: name, color: color, protected: protected)
    }
    
    func get(name: String) -> Tag? {
        return list[name]
    }
    
    func getAll() -> [Tag] {
        let unsorted = Set(list.values)
        return TagsKeeper.sort(tags: unsorted)
    }
    
    func delete(tag: Tag) {
        list.removeValue(forKey: tag.name)
        for alias in tag.aliases {
            list.removeValue(forKey: alias)
        }
        tag.delete()
    }
    
    func fit() {
        for tag in [Tag](list.values) {
            if !tag.protected && tag.infiles.count == 0 {
                delete(tag: tag)
            }
        }
    }
    
    func changeName(tag: Tag, name: String) throws {
        let name = try normalizeAndCheckName(name: name)
        print("[TagsKeeper][Info] Change name of \"\(tag.name)\" to \(name)")
        let old = tag.name
        list[old] = nil
        tag.name = name
        list[name] = tag
    }
    
    func addAlias(tag: Tag, alias: String) throws {
        let alias = try normalizeAndCheckName(name: alias)
        tag.add(alias: alias)
        list[alias] = tag
    }
    
    func removeAlias(tag: Tag, alias: String) {
        tag.remove(alias: alias)
        list[alias] = nil
    }
    
    func normalizeAndCheckName(name: String) throws -> String {
        let name = name.trimAndClean()
        guard !name.isEmpty else { throw TagError.emptyName }
        guard list[name] == nil else { throw TagError.reservedName }
        for reserve in reserved {
            if name.contains(reserve) {
                throw TagError.reservedCharacter(reserve)
            }
        }
        return name
    }
    
    func info() {
        print("[TagsKeeper][Debug] Tags info:")
        for tag in list.values.sorted(by: {$0.name < $1.name}) {
            var info = tag.name + ": "
            for infile in tag.infiles {
                info += (infile as! Infile).name + ", "
            }
            print(info.dropLast(2))
        }
    }
    
    static func sort(tags: Set<Tag>) -> [Tag] {
        return tags.sorted {
            let color0 = $0.color.ahsv()
            let color1 = $1.color.ahsv()
            if color0 != color1 {
                return color0 < color1
            } else {
                return $0.name < $1.name
            }
        }
    }
}

enum TagError: Error {
    case emptyName
    case reservedName
    case reservedCharacter(String)
}
