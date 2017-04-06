//
//  BluetoothService.swift
//  reflekto
//
//  Created by Michał Kwiecień on 06.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothServiceManager: NSObject {
    
    let BLUETOOTH_NOT_AVAILABLE_CODE = 200
    
    fileprivate var central: CBCentralManager!
    fileprivate var peripheral: CBPeripheral!
    
    fileprivate var cbuuid: CBUUID?
    fileprivate var serviceCBUUIDs: [CBUUID]?
    fileprivate var characteristicsCBUUIDs: [CBUUID]?
    
    var peripheralConnectionSuccess: ((_ peripheral: CBPeripheral) -> (Void))?
    var peripheralConnectionFailure: ((_ peripheral: CBPeripheral?, _ error: Error?) -> (Void))?
    var peripheralDisconnected: ((_ peripheral: CBPeripheral, _ error: Error?) -> (Void))?
    
    func connectToMirror(withUUID uuid: UUID, serviceUUIDs: [UUID], characteristicsUUIDs: [UUID]) {
        self.cbuuid = CBUUID(nsuuid: uuid)
        self.serviceCBUUIDs = serviceUUIDs.map { CBUUID(nsuuid: $0) }
        self.characteristicsCBUUIDs = characteristicsUUIDs.map { CBUUID(nsuuid: $0) }
        
        
        let bluetoothQueue = DispatchQueue(label: "com.solstico.reflekto.bluetooth")
        central = CBCentralManager(delegate: self, queue: bluetoothQueue)
        guard central.state == .poweredOn else {
            peripheralConnectionFailure?(nil, NSError(domain: "bluetooth", code: BLUETOOTH_NOT_AVAILABLE_CODE, userInfo: nil))
            return
        }
        central.scanForPeripherals(withServices: [cbuuid!], options: nil)
    }
    
}

extension BluetoothServiceManager: CBCentralManagerDelegate {
    
    //MARK: Bluetooth state handlers
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            peripheralConnectionFailure?(nil, NSError(domain: "bluetooth", code: BLUETOOTH_NOT_AVAILABLE_CODE, userInfo: nil))
            return
        }
//        guard let cbuuid = self.cbuuid else { return }
        //TODO: ONLY FOR TESTS, CHANGE THAT!!!!
//        central.scanForPeripherals(withServices: [cbuuid], options: nil)
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    //MARK: Discover handlers
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered \(peripheral) with advertisementData: \(advertisementData)")
        //TODO: ONLY FOR TESTS, CHANGE THAT!!!!
        if let name = peripheral.name, name == "Reflekto_UART" {
            self.peripheral = peripheral
            central.stopScan()
            central.connect(peripheral, options: nil)
        }
    }
    
    
    
    //MARK: Connection handlers
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to  \(peripheral)")
        peripheral.delegate = self
        peripheral.discoverServices(serviceCBUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.peripheralConnectionFailure?(peripheral, error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.peripheralDisconnected?(peripheral, error)
        }
    }
    
}

extension BluetoothServiceManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Discovered  services: \(String(describing: peripheral.services)) for peripheral: \(peripheral)")
        guard let service = peripheral.services?.first else { return }
        peripheral.discoverCharacteristics(characteristicsCBUUIDs, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Discovered  characteristics: \(String(describing: service.characteristics)) for peripheral: \(peripheral)")
        DispatchQueue.main.async {
            self.peripheralConnectionSuccess?(peripheral)
        }
    }
    
}
