/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
    
    let disposeBag = DisposeBag()
    
    fileprivate let MAX_PACKAGE_SIZE = 18 //in bytes
    fileprivate let TIME_TO_RETRY_CONNECTING: TimeInterval = 4 //in seconds
    
    //change here if services and characteristics count will change in the future
    fileprivate let servicesToDiscoverCount = 4
    fileprivate let characteristicsToDiscoverCount = 11
    
    fileprivate var manager: CBCentralManager!
    fileprivate var mirrorPeripheral: CBPeripheral!
    fileprivate let bluetoothQueue = DispatchQueue(label: "com.solstico.reflekto.bluetooth")
    
    //services CBUUIDs
    fileprivate static let advertisementServiceCBUUID = CBUUID(string: "74686973-2069-7320-7265-666c656b746f")
    fileprivate static let timeServiceCBUUID = CBUUID(string: "74681805-2069-7320-7265-666c656b746f")
    fileprivate static let weatherServiceCBUUID = CBUUID(string: "74680010-2069-7320-7265-666c656b746f")
    fileprivate static let personalInfoServiceCBUUID = CBUUID(string: "74680020-2069-7320-7265-666c656b746f")
    fileprivate static let configurationServiceCBUUID = CBUUID(string: "7468DEAD-2069-7320-7265-666c656b746f")
    
    //characteristics CBUUIDs and objects
    fileprivate static let timeCharacteristicCBUUID = CBUUID(string: "74682A2B-2069-7320-7265-666c656b746f")
    fileprivate static let weatherCityCharacteristicCBUUID = CBUUID(string: "74680011-2069-7320-7265-666c656b746f")
    fileprivate static let weatherWindCharacteristicCBUUID = CBUUID(string: "74680012-2069-7320-7265-666c656b746f")
    fileprivate static let weatherAdditionalCharacteristicCBUUID = CBUUID(string: "74680013-2069-7320-7265-666c656b746f")
    fileprivate static let nextEventCharacteristicCBUUID = CBUUID(string: "74680021-2069-7320-7265-666c656b746f")
    fileprivate static let unreadEmailsCharacteristicCBUUID = CBUUID(string: "74680022-2069-7320-7265-666c656b746f")
    fileprivate static let travelTimeCharacteristicCBUUID = CBUUID(string: "74680023-2069-7320-7265-666c656b746f")
    fileprivate static let nameCharacteristicCBUUID = CBUUID(string: "74680024-2069-7320-7265-666c656b746f")
    fileprivate static let greetingCharacteristicCBUUID = CBUUID(string: "74680025-2069-7320-7265-666c656b746f")
    fileprivate static let complimentCharacteristicCBUUID = CBUUID(string: "74680026-2069-7320-7265-666c656b746f")
    fileprivate static let configurationCharacteristicCBUUID = CBUUID(string: "7468BEEF-2069-7320-7265-666c656b746f")
    
    fileprivate var timeCharacteristic: CBCharacteristic!
    fileprivate var weatherCityCharacteristic: CBCharacteristic!
    fileprivate var weatherWindCharacteristic: CBCharacteristic!
    fileprivate var weatherAdditionalCharacteristic: CBCharacteristic!
    fileprivate var nextEventCharacteristic: CBCharacteristic!
    fileprivate var unreadEmailsCharacteristic: CBCharacteristic!
    fileprivate var travelTimeCharacteristic: CBCharacteristic!
    fileprivate var nameCharacteristic: CBCharacteristic!
    fileprivate var greetingCharacteristic: CBCharacteristic!
    fileprivate var complimentCharacteristic: CBCharacteristic!
    fileprivate var configurationCharacteristic: CBCharacteristic!
    
    //CBUUIDS arrays for Core Bluetooth
    fileprivate var advertisedServicesToDiscover: [CBUUID]? = [advertisementServiceCBUUID]
    fileprivate var serviceCBUUIDs: [CBUUID]? = [timeServiceCBUUID, weatherServiceCBUUID, personalInfoServiceCBUUID, configurationServiceCBUUID]
    fileprivate var characteristicsCBUUIDs: [CBUUID]? = [timeCharacteristicCBUUID, weatherCityCharacteristicCBUUID, weatherWindCharacteristicCBUUID, weatherAdditionalCharacteristicCBUUID, nextEventCharacteristicCBUUID, unreadEmailsCharacteristicCBUUID, travelTimeCharacteristicCBUUID, nameCharacteristicCBUUID, greetingCharacteristicCBUUID, complimentCharacteristicCBUUID, configurationCharacteristicCBUUID]
    
    //helper counters
    fileprivate var characteristicsDiscoveredCount = 0
    
    override init() {
        super.init()
        if mirrorPeripheral != nil {
            manager.cancelPeripheralConnection(mirrorPeripheral)
        }
        manager = CBCentralManager(delegate: self, queue: bluetoothQueue)
    }
    
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    //MARK: Bluetooth state handlers
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            return
        }
        print("----------- Scanner turned on ------------------")
        manager.scanForPeripherals(withServices: advertisedServicesToDiscover)
    }
    
    //MARK: Discover handlers
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("----------- Mirror discovered ------------------")
        central.stopScan()
        self.mirrorPeripheral = peripheral
        central.connect(mirrorPeripheral, options: nil)
    }
    
    //MARK: Connection handlers
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("----------- Connected to Bluetooth mirror ------------------")
        if peripheral == mirrorPeripheral {
            mirrorPeripheral.delegate = self
            clearDiscoveredItems()
            mirrorPeripheral.discoverServices(serviceCBUUIDs)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("----------- Failed to connect ------------------")
        createReconnectionTimer()
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("----------- Diconnected from Bluetooth mirror ------------------")
        createReconnectionTimer()
    }
    
    private func createReconnectionTimer() {
        let reconnectTimer = Timer.init(timeInterval: TIME_TO_RETRY_CONNECTING, repeats: false, block: { [unowned self] _ in
            print("----------- Scanner turned on again ------------------")
            self.manager.connect(self.mirrorPeripheral, options: nil)
        })
        RunLoop.main.add(reconnectTimer, forMode: .defaultRunLoopMode)
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
            print("----------- Discovered characteristics ------------------")
            onAllCharacteristicsDiscovered()
        }
    }
    
    private func mapCharacteristicsToObjects(_ characteristics: [CBCharacteristic]) {
        for characteristic in characteristics {
            switch characteristic.uuid {
            case BluetoothManager.timeCharacteristicCBUUID:
                timeCharacteristic = characteristic
            case BluetoothManager.weatherCityCharacteristicCBUUID:
                weatherCityCharacteristic = characteristic
            case BluetoothManager.weatherWindCharacteristicCBUUID:
                weatherWindCharacteristic = characteristic
            case BluetoothManager.weatherAdditionalCharacteristicCBUUID:
                weatherAdditionalCharacteristic = characteristic
            case BluetoothManager.nextEventCharacteristicCBUUID:
                nextEventCharacteristic = characteristic
            case BluetoothManager.unreadEmailsCharacteristicCBUUID:
                unreadEmailsCharacteristic = characteristic
            case BluetoothManager.travelTimeCharacteristicCBUUID:
                travelTimeCharacteristic = characteristic
            case BluetoothManager.nameCharacteristicCBUUID:
                nameCharacteristic = characteristic
            case BluetoothManager.greetingCharacteristicCBUUID:
                greetingCharacteristic = characteristic
            case BluetoothManager.complimentCharacteristicCBUUID:
                complimentCharacteristic = characteristic
            case BluetoothManager.configurationCharacteristicCBUUID:
                configurationCharacteristic = characteristic
            default:
                print("Error whille mapping characteristic: \(characteristic.uuid.uuidString)")
                break
            }
        }
    }
    
}

//MARK: Write methods
extension BluetoothManager {
    
    fileprivate func initializeConnection() {
        if mirrorPeripheral.state == .connected {
            let swiftData: [Int8] = [0x0, 0x0, 0x1, 0x2, 0x2, 0x0]
            let data = Data(bytes: swiftData, count: swiftData.count)
            mirrorPeripheral.writeValue(data, for: configurationCharacteristic, type: .withResponse)
        }
    }
    
    fileprivate func disconnectInstatly() {
        if mirrorPeripheral.state == .connected {
            let swiftData: [Int8] = [0x6, 0x6, 0x6]
            let data = Data(bytes: swiftData, count: swiftData.count)
            mirrorPeripheral.writeValue(data, for: configurationCharacteristic, type: .withResponse)
        }
    }
    
}

//MARK: Manager helpers
extension BluetoothManager {
    
    fileprivate func clearDiscoveredItems() {
        self.characteristicsDiscoveredCount = 0
    }
    
    fileprivate func onAllCharacteristicsDiscovered() {
        onRangeChagedToNearby()
    }
    
    fileprivate func onRangeChagedToNearby() {
        fetchDataAndWriteToMirror()
    }
    
    private func fetchDataAndWriteToMirror() {
        initializeConnection()
        Observable.zip(DataManager.timestamp, DataManager.weather, DataManager.nextEvent, DataManager.name, DataManager.greeting, DataManager.compliment, DataManager.unreadMailsCount, DataManager.travelToWorkTime)
            .subscribe(onNext: { [weak self] (timestamp, weather, nextEvent, name, greeting, compliment, unreadMailsCount, travelWorkTime) in
                guard let strongSelf = self else { return }
                var timestamp = timestamp
                print("Timestamp: \(timestamp)")
                print("Weather 1: \(weather.city)")
                print("Weather 2: \(weather.wind)")
                print("Weather 3: \(weather.additionalInfo)")
                print("Next Event: \(nextEvent)")
                print("Greeting: \(greeting)")
                print("Compliment: \(compliment)")
                print("You have \(unreadMailsCount) unread emails")
                print("\(travelWorkTime) min to get work")
                strongSelf.mirrorPeripheral.writeValue(Data(bytes: &timestamp, count: 4), for: strongSelf.timeCharacteristic, type: .withResponse)
                strongSelf.write(string: weather.city, toCharacteristic: strongSelf.weatherCityCharacteristic)
                strongSelf.write(string: weather.wind, toCharacteristic: strongSelf.weatherWindCharacteristic)
                strongSelf.write(string: weather.additionalInfo, toCharacteristic: strongSelf.weatherAdditionalCharacteristic)
                strongSelf.write(string: name, toCharacteristic: strongSelf.nameCharacteristic)
                strongSelf.write(string: greeting, toCharacteristic: strongSelf.greetingCharacteristic)
                strongSelf.write(string: compliment, toCharacteristic: strongSelf.complimentCharacteristic)
                strongSelf.write(string: "\(travelWorkTime) min to get work", toCharacteristic: strongSelf.travelTimeCharacteristic)
                strongSelf.write(string: "You have \(unreadMailsCount) unread emails", toCharacteristic: strongSelf.unreadEmailsCharacteristic)
                strongSelf.write(string: "Next Event: \(nextEvent)", toCharacteristic: strongSelf.nextEventCharacteristic)
                strongSelf.disconnectInstatly()
            })
            .addDisposableTo(disposeBag)
    }
    
}

//MARK: Writing data helpers
extension BluetoothManager {
    
    fileprivate func write(string: String?, toCharacteristic characteristic: CBCharacteristic) {
        guard let string = string else { return }
        let withoutDiactirics = string.removedDiacritics
        guard let data = withoutDiactirics.data(using: .utf8) else { return }
        let dividedData = data.divideIntoPackages(maxPackageSizeInBytes: MAX_PACKAGE_SIZE)
        for eachData in dividedData {
            mirrorPeripheral.writeValue(eachData, for: characteristic, type: .withResponse)
        }
    }
    
}

