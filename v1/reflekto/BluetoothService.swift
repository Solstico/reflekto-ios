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
    fileprivate var timer: Timer!
    
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
            return
        }
        central.scanForPeripherals(withServices: [cbuuid!], options: nil)
    }
    
    func disconnect(peripheral: CBPeripheral) {
        print("I'm trying to disconnect")
        central.cancelPeripheralConnection(peripheral)
    }
    
}

extension BluetoothServiceManager: CBCentralManagerDelegate {
    
    //MARK: Bluetooth state handlers
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            return
        }
        guard let cbuuid = self.cbuuid else { return }
//        cbuuid = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
        central.scanForPeripherals(withServices: [cbuuid], options: nil)
        print("run scanner")
    }
    
    //MARK: Discover handlers
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        central.stopScan()
        central.connect(peripheral, options: nil)
    }
    
    
    
    //MARK: Connection handlers
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(serviceCBUUIDs)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        DispatchQueue.main.async {
            self.peripheralConnectionFailure?(peripheral, error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("I'm disconnected")
        DispatchQueue.main.async {
            self.peripheralDisconnected?(peripheral, error)
        }
        timer = Timer.init(timeInterval: 3.0, repeats: false) { _ in
            print("I'm starting scanning again")
            self.central.scanForPeripherals(withServices: [self.cbuuid!], options: nil)
        }
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
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