//
//  String+trimAndClean.swift
//  Abstore
//
//  Created by Abionics on 9/29/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

extension String {
    func trimAndClean() -> String {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let components = trimmed.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
