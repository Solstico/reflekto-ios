//
//  DataExtension.swift
//  reflekto
//
//  Created by Michał Kwiecień on 10.05.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation

extension Data {
    
    func divideIntoPackages(maxPackageSizeInBytes: Int) -> [Data] {
        let startOfTextData = Data(repeating: 0x02, count: 1)
        let endOfTextData = Data(repeating: 0x03, count: 1)
        if self.count > maxPackageSizeInBytes {
            var toReturnDatas = [Data]()
            var package = Data()
            for (index, byte) in self.enumerated() {
                if index == 0 {
                    package.append(startOfTextData)
                }
                if index == self.count - 1 {
                    package.append(byte)
                    package.append(endOfTextData)
                }
                
                if package.count >= maxPackageSizeInBytes || index == self.count - 1 {
                    toReturnDatas.append(package)
                    package = Data()
                    package.append(byte)
                } else {
                    package.append(byte)
                }
            }
            return toReturnDatas
        } else {
            var toReturnData = Data()
            toReturnData.append(startOfTextData)
            toReturnData.append(self)
            toReturnData.append(endOfTextData)
            return [toReturnData]
        }
    }
    
}
