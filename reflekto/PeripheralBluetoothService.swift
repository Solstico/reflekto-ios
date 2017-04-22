
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
    
    var bluetoothService: BluetoothServiceManager?
    var writtenData = 0
    var rangeDidChangedToNearby: (() -> (Void))?
    
    let MAX_PACKAGE_BYTES = 20
    
    var peripheral: CBPeripheral!
    
    var characteristic: CBCharacteristic? {
        return peripheral.services?.first?.characteristics?.first
    }
    
    init(withPeripheral peripheral: CBPeripheral) {
        super.init()
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.readRSSI()
    }
    
    func write(string: String?) {
        guard let string = string else { return }
        let withoutDiactirics = string.folding(options: .diacriticInsensitive, locale: Locale.current)
        let data = withoutDiactirics.data(using: .utf8)!
        write(data: data)
    }
    
    private func write(data: Data) {
        guard let characteristic = characteristic else { return }
        var returnData = data
        let bytesCount = data.count
        let different = bytesCount - MAX_PACKAGE_BYTES
        if different > 0 {
            returnData = Data(returnData.dropLast(different))
        }
        peripheral.writeValue(returnData, for: characteristic, type: .withResponse)
    }
    
}

extension PeripheralBluetoothService: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Data was written")
        writtenData += 1
        if writtenData >= BackgroundService.dataNeededToDownload {
            writtenData = 0
            bluetoothService?.disconnect(peripheral: peripheral)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        print("Dostałem RSSI: \(RSSI)")
        if Int(RSSI) > -60 {
            rangeDidChangedToNearby?()
        } else {
            bluetoothService?.disconnect(peripheral: peripheral)
        }
    }
    
}
