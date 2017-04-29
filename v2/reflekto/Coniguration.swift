//
//  Coniguration.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import RxSwift


class Configuration {
    
    static let name = Variable<String>(nameConfiguration)
    static let sex = Variable<Sex>(sexConfiguration)
    static let homeLocation = Variable<Location>(homeLocationConfiguration)
    static let workLocation = Variable<Location>(workLocationConfiguration)
    
    class var hasEverything: Bool {
        let nameValidation = nameConfiguration != ""
        let sexValidation = sexConfiguration != .notSet
        let homeLocationValidation = homeLocationConfiguration != Location(lon: 0, lat: 0)
        let workLocationValidation = workLocationConfiguration != Location(lon: 0, lat: 0)
        return nameValidation && sexValidation && homeLocationValidation && workLocationValidation
    }
    
    class func set(name: String) {
        nameConfiguration = name
    }
    
    class func set(sex: Sex) {
        sexConfiguration = sex
    }
    
    class func set(homeLocation: Location) {
        homeLocationConfiguration = homeLocation
    }
    
    class func set(workLocation: Location) {
        workLocationConfiguration = workLocation
    }
    
    class private var nameConfiguration: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "name")
            name.value = newValue
        }
        get {
            return UserDefaults.standard.string(forKey: "name") ?? ""
        }
    }
    
    class private var sexConfiguration: Sex {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "sex")
            sex.value = newValue
        }
        get {
            return Sex(rawValue: UserDefaults.standard.integer(forKey: "sex"))!
        }
    }
    
    class private var homeLocationConfiguration: Location {
        set {
            UserDefaults.standard.set(newValue.lon, forKey: "homeLongitude")
            UserDefaults.standard.set(newValue.lat, forKey: "homeLatitude")
            homeLocation.value = newValue
        }
        get {
            let longitude = UserDefaults.standard.double(forKey: "homeLongitude")
            let latitude = UserDefaults.standard.double(forKey: "homeLatitude")
            return Location(lon: longitude, lat: latitude)
        }
    }
    
    class private var workLocationConfiguration: Location {
        set {
            UserDefaults.standard.set(newValue.lon, forKey: "workLongitude")
            UserDefaults.standard.set(newValue.lat, forKey: "workLatitude")
            workLocation.value = newValue
        }
        get {
            let longitude = UserDefaults.standard.double(forKey: "workLongitude")
            let latitude = UserDefaults.standard.double(forKey: "workLatitude")
            return Location(lon: longitude, lat: latitude)
        }
    }
    
}
