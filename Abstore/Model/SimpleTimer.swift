//
//  SimpleTimer.swift
//  Abstore
//
//  Created by Abionics on 8/18/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import Foundation

class SimpleTimer {
    var startTime: Int64 = 0
    
    init() {
        start()
    }
    
    func current() -> Int64 {
        let timeInterval = Date().timeIntervalSince1970 * 1000.0
        return Int64(timeInterval)
    }
    
    func start() {
        startTime = current()
    }
    
    func time() -> Int64 {
        return current() - startTime
    }
    
    func stime() -> String {
        return String(time()) + " ms"
    }
    
    func round() -> Int64 {
        let result = time()
        start()
        return result
    }
    
    func print() {
        Swift.print("Time: " + stime())
    }
}
