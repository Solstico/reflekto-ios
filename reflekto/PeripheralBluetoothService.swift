
//
//  PeripheralService.swift
//  reflekto
//
//  Created by Michał Kwiecień on 06.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import CoreBluetooth

class PeripheralBluetoothService: NSObject {
    
    var peripheral: CBPeripheral!
    
    var characteristic: CBCharacteristic? {
        return peripheral.services?.first?.characteristics?.first
    }
    
    init(withPeripheral peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        peripheral.delegate = self
    }
    
    func write(string: String?) {
        guard let string = string else { return }
        let withoutDiactirics = string.folding(options: .diacriticInsensitive, locale: Locale.current)
        let data = withoutDiactirics.data(using: .utf8)!
        write(data: data)
    }
    
    private func write(data: Data) {
        guard let characteristic = characteristic else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
}

extension PeripheralBluetoothService: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Data was written")
    }
    
}
