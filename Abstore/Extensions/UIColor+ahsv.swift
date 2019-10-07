//
//  UIColor+hsv.swift
//  Abstore
//
//  Created by Abionics on 9/30/19.
//  Copyright © 2019 Abionics. All rights reserved.
//

import UIKit

extension UIColor {
    func ahsv(_ size: CGSize = UIScreen.main.bounds.size) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (alpha, hue, saturation, brightness)
    }
}
