/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
