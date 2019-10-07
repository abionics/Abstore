//
//  InfilesKeeper.swift
//  Abstore
//
//  Created by Abionics on 8/15/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

class InfilesKeeper {
    private var list = [String: Infile]()
    
    func add(_ infile: Infile) {
        list[infile.name] = infile
    }
    
    func info() {
        print("[InfilesKeeper][Debug] Infiles info:")
        for infile in list.values.sorted(by: {$0.creationDate > $1.creationDate}) {
            var info = infile.name + ": "
            for tag in infile.tags {
                info += (tag as! Tag).name + ", "
            }
            print(info.dropLast(2))
        }
    }
}
