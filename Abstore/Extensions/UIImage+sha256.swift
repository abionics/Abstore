//
//  UIImage+sha256.swift
//  Abstore
//
//  Created by Abionics on 8/17/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit
import CommonCrypto

extension UIImage {
    public func sha256() -> String {
        guard let imageData = cgImage?.dataProvider?.data as Data? else { return "" }
        return hexStringFromData(input: digest(input: imageData as NSData))
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}
