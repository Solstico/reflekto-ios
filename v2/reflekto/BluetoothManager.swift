//
//  BluetoothManager.swift
//  reflekto
//
//  Created by Michał Kwiecień on 30.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

class BluetoothManager: NSObject {
    
    fileprivate let servicesToDiscoverCount = 1
    fileprivate let characteristicsToDiscoverCount = 1
    fileprivate var characteristicsDiscoveredCount = 0
    
    fileprivate var manager: CBCentralManager!
    fileprivate var mirrorPeripheral: CBPeripheral!
    fileprivate let bluetoothQueue = DispatchQueue(label: "com.solstico.reflekto.bluetooth")
    
    //services CBUUIDs
    fileprivate static let firstServiceCBUUID = CBUUID(string: "00000700-0000-1000-8000-00805f9b34fb")
    
    //characteristics CBUUIDs and objects
    fileprivate static let disconnectionCharacteristicCBUUID = CBUUID(string: "00000002-1212-EFDE-1523-785FEF037000")
    fileprivate var disconnectionCharacteristic: CBCharacteristic!
    
    //CBUUIDS arrays for Core Bluetooth
    fileprivate var advertisedServicesToDiscover: [CBUUID]? = [firstServiceCBUUID]
    fileprivate var serviceCBUUIDs: [CBUUID]? = [firstServiceCBUUID]
    fileprivate var characteristicsCBUUIDs: [CBUUID]? = [disconnectionCharacteristicCBUUID]
    
    
    
    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: bluetoothQueue)
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    //MARK: Bluetooth state handlers
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            return
        }
        manager.scanForPeripherals(withServices: advertisedServicesToDiscover)
    }
    
    //MARK: Discover handlers
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        central.stopScan()
        self.mirrorPeripheral = peripheral
        central.connect(mirrorPeripheral, options: nil)
    }
    
    //MARK: Connection handlers
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("----------- Connected to Bluetooth mirror ------------------")
        if peripheral == mirrorPeripheral {
            clearDiscoveredItems()
            mirrorPeripheral.delegate = self
            mirrorPeripheral.discoverServices(serviceCBUUIDs)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("----------- Failed to connect ------------------")
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [unowned self] _ in
            self.manager.scanForPeripherals(withServices: self.advertisedServicesToDiscover)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("----------- Diconnected from Bluetooth mirror ------------------")
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [unowned self] _ in
            self.manager.scanForPeripherals(withServices: self.advertisedServicesToDiscover)
        }
    }
    
}

extension BluetoothManager: CBPeripheralDelegate {
    
    //MARK: Discovery services and characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services, services.count >= servicesToDiscoverCount else { return }
        for service in services {
            peripheral.discoverCharacteristics(characteristicsCBUUIDs, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics, characteristics.count > 0 else { return }
        self.mapCharacteristicsToObjects(characteristics)
        self.characteristicsDiscoveredCount += characteristics.count
        if characteristicsDiscoveredCount >= characteristicsToDiscoverCount {
            onAllCharacteristicsDiscovered()
        }
    }
    
    private func mapCharacteristicsToObjects(_ characteristics: [CBCharacteristic]) {
        for characteristic in characteristics {
            switch characteristic.uuid {
            case BluetoothManager.disconnectionCharacteristicCBUUID:
                disconnectionCharacteristic = characteristic
            default:
                break
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if Int(RSSI) > -69 {
            onRangeChagedToNearby()
        } else {
            disconnectInstatly()
        }
    }
    
}

//MARK: Write methods
extension BluetoothManager {
    
    fileprivate func disconnectInstatly() {
        let swiftData: [Int8] = [0x0, 0x0, 0x1, 0x2, 0x2, 0x0]
        let data = Data(bytes: swiftData, count: swiftData.count)
        mirrorPeripheral.writeValue(data, for: disconnectionCharacteristic, type: .withResponse)
    }
    
}

//MARK: Manager helpers
extension BluetoothManager {
    
    fileprivate func clearDiscoveredItems() {
        self.characteristicsDiscoveredCount = 0
    }
    
    fileprivate func onAllCharacteristicsDiscovered() {
        mirrorPeripheral.readRSSI()
    }
    
    fileprivate func onRangeChagedToNearby() {
        Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { [unowned self] _ in
            self.disconnectInstatly()
        }
        //TODO: Do everything here! (mirror is close enough and all characteristics are discovered)
        
    }
    
}

