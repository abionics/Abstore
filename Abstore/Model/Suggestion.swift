//
//  Suggestion.swift
//  Abstore
//
//  Created by Abionics on 10/7/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

class Suggestion {
    let COUNT = 3
    var list = [String: (value: String, count: Int)]()
    
    init() {
        setup()
    }
    
    func setup() {
        let tags = Storage.instance.tags.getAll()
        list = [:]
        for tag in tags {
            let name = tag.name
            let count = tag.infiles.count
            list[name] = (name, count)
            for alias in tag.aliases {
                list[alias] = (name, count)
            }
        }
    }
    
    func suggest(text: String) -> [(value: String, from: Int)] {
        print("SEAAA")
        let reserved = Parser.reserved
        var lastIndex = text.startIndex
        for reserve in reserved {
            if let index = text.range(of: reserve, options: .backwards)?.lowerBound {
                let end = text.index(index, offsetBy: reserve.count, limitedBy: text.endIndex)
                lastIndex = max(lastIndex, end!)
            }
        }
        
        var result = suggest(normalized: String(text[lastIndex...]))
        guard result.count > 0 else { return [] }
        let from = text.distance(from: text.startIndex, to: lastIndex)
        for i in 0...result.count - 1 {
            result[i].from += from
        }
        //todo rem duplicates "alert al" (alert, alarm)
        return result
    }
    
    func suggest(normalized text: String) -> [(value: String, from: Int)] {
        print("search '\(text)'")
        var suggestions = [(String, Int)]()
        var from = 0
        var pattern = " " + text
        while let spaceIndex = pattern.firstIndex(of: " ") {
            let index = pattern.index(spaceIndex, offsetBy: 1)
            let position = pattern.distance(from: pattern.startIndex, to: index)
            pattern = String(pattern[index...])
            from += position;
            
            let result = suggest(word: pattern)
            print("result", result)
            for res in result {
                suggestions.append((res, from))
            }
        }
        print("RESULT", suggestions)
        return suggestions
    }
    
    func suggest(word: String) -> [String] {
        print("'\(word)'")
        var result = [String: Int]()
        for (pattern, original) in list {
            if pattern.hasPrefix(word) {
                result[original.value] = result[original.value] ?? 0 + original.count
            }
        }
        print(result)
        return result.keys.sorted {
            let val0 = result[$0]!
            let val1 = result[$1]!
            return (val0 > val1) || (val0 == val1 && $0 < $1)
        }
    }
}
