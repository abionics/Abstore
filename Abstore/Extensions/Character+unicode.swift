//
//  Character+unicode.swift
//  Abstore
//
//  Created by Abionics on 8/17/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

extension Character {
    var unicode: UInt32 {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        return scalars[scalars.startIndex].value
    }
}
