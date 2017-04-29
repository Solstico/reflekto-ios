//
//  Coniguration.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation


class Configuration {
    
    class var name: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "name")
        }
        get {
            return UserDefaults.standard.string(forKey: "name") ?? ""
        }
    }
    
    class var sex: Sex {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "sex")
        }
        get {
            return Sex(rawValue: UserDefaults.standard.integer(forKey: "sex"))!
        }
    }
    
    class var homeLocation: (lon: Double, lat: Double) {
        set {
            UserDefaults.standard.set(newValue.lon, forKey: "homeLongitude")
            UserDefaults.standard.set(newValue.lat, forKey: "homeLatitude")
        }
        get {
            let longitude = UserDefaults.standard.double(forKey: "homeLongitude")
            let latitude = UserDefaults.standard.double(forKey: "homeLatitude")
            return (lon: longitude, lat: latitude)
        }
    }
    
    class var workLocation: (lon: Double, lat: Double) {
        set {
            UserDefaults.standard.set(newValue.lon, forKey: "workLongitude")
            UserDefaults.standard.set(newValue.lat, forKey: "workLatitude")
        }
        get {
            let longitude = UserDefaults.standard.double(forKey: "workLongitude")
            let latitude = UserDefaults.standard.double(forKey: "workLatitude")
            return (lon: longitude, lat: latitude)
        }
    }
    
}
