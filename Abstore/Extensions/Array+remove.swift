//
//  Array+ remove.swift
//  Abstore
//
//  Created by Abionics on 8/19/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

extension Array {
    mutating func remove(object: AnyObject) {
        if let index = firstIndex(where: { $0 as AnyObject === object }) {
            remove(at: index)
        }
    }
}
