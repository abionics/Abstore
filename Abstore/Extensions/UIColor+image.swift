//
//  UIColor+image.swift
//  Abstore
//
//  Created by Abionics on 9/2/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

extension UIColor {
    func image(_ size: CGSize = UIScreen.main.bounds.size) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
