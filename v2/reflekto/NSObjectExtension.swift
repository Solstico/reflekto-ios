//
//  NSObjectExtension.swift
//  ios-vrl
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation

extension NSObject {
    
    class var className: String {
        let namespaceClassName = NSStringFromClass(self)
        return namespaceClassName.components(separatedBy: ".").last!
    }
    
    var className: String {
        let namespaceClassName = NSStringFromClass(self.classForCoder)
        return namespaceClassName.components(separatedBy: ".").last!
    }
}
