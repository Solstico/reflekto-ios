//
//  UIColorExtension.swift
//  ios-vrl
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex: Int) {
        let red = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 08) & 0xff) / 255
        let blue = CGFloat((hex >> 00) & 0xff) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
    
    
    //Adobe Color palette: https://color.adobe.com/pl/iOS-a-color-theme-8204966/
    
    class var refRed: UIColor {
        return UIColor(hex: 0xFF3B30)
    }
    
    class var refOrange: UIColor {
        return UIColor(hex: 0xFF9500)
    }
    
    class var refYellow: UIColor {
        return UIColor(hex: 0xFFCC00)
    }
    
    class var refGreen: UIColor {
        return UIColor(red: 11/255, green: 162/255, blue: 1/255, alpha: 1.0)
    }
    
    class var refBlue: UIColor {
        return UIColor(hex: 0x5AC8FA)
    }
    
}
