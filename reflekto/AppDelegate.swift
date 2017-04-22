//
//  AppDelegate.swift
//  reflekto
//
//  Created by Michał Kwiecień on 11.02.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let bluetoothService = BluetoothServiceManager()
    var peripheralService: PeripheralBluetoothService?
    let backgroundService = BackgroundService()


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        print("Resign active")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        print("enter background")
        connectToBLEDevice()
        backgroundService.dataPrepared = {
            self.sendAllData()
        }
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        print("enter foreground")
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        print("did become active")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        print("will terminate")
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    private func connectToBLEDevice() {
        let deviceUUID = UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!
        let servicesUUIDs = [UUID(uuidString: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")!]
        let characteristicsUUIDs = [UUID(uuidString: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")!]
        
        bluetoothService.peripheralConnectionSuccess = { [weak self] peripheral in
            guard let strongSelf = self else { return }
            print("Jestem połączony z peripheralem: \(peripheral)")
            strongSelf.peripheralService = PeripheralBluetoothService(withPeripheral: peripheral)
            strongSelf.backgroundService.prepareAllData()
        }
        
        bluetoothService.peripheralConnectionFailure = { peripheral, error in
            print("Błąd łączenia z peripheralem: \(String(describing: peripheral)) \n błąd: \(String(describing: error))")
        }
        
        bluetoothService.peripheralDisconnected = { peripheral, error in
            print("Rozłączyłem się z peripheralem: \(String(describing: peripheral)) \n błąd: \(String(describing: error))")
        }
        
        bluetoothService.connectToMirror(withUUID: deviceUUID, serviceUUIDs: servicesUUIDs, characteristicsUUIDs: characteristicsUUIDs)
    }
    
    private func sendAllData() {
        peripheralService?.write(string: "00\(backgroundService.time ?? "")")
        peripheralService?.write(string: "10\(backgroundService.weather ?? "")")
        peripheralService?.write(string: "20\(backgroundService.greeting ?? "")")
        peripheralService?.write(string: "30\(backgroundService.name ?? "")")
        peripheralService?.write(string: "40\(backgroundService.sex ?? "")")
        peripheralService?.write(string: "50\(backgroundService.compliment ?? "")")
        peripheralService?.write(string: "60\(backgroundService.weatherAdditional ?? "")")
        peripheralService?.write(string: "70\(backgroundService.weatherAdvice ?? "")")
        peripheralService?.write(string: "80\(backgroundService.nextEvent ?? "")")
    }

}

