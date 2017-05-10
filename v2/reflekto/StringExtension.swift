//
//  StringExtension.swift
//  reflekto
//
//  Created by Michał Kwiecień on 10.05.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation

extension String {

    var removedDiacritics: String {
        let mStringRef = NSMutableString(string: self) as CFMutableString
        CFStringTransform(mStringRef, nil, kCFStringTransformStripCombiningMarks, false)
        let toReturn = mStringRef as String
        let small = toReturn.replacingOccurrences(of: "ł", with: "l")
        return small.replacingOccurrences(of: "Ł", with: "L")
    }
    
}
