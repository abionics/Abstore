//
//  String+Character.swift
//  Abstore
//
//  Created by Abionics on 8/17/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

extension Character {
    static func +(string: String, char: Character) -> String {
        var result = string
        result.append(char)
        return result
    }
}
