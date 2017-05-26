/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
    static let city = Variable<String>(cityConfiguration)
    
    class var hasEverything: Bool {
        let nameValidation = nameConfiguration != ""
        let cityValidation = cityConfiguration != ""
        let sexValidation = sexConfiguration != .notSet
        let homeLocationValidation = homeLocationConfiguration != Location(lon: 0, lat: 0)
        let workLocationValidation = workLocationConfiguration != Location(lon: 0, lat: 0)
        return nameValidation && cityValidation && sexValidation && homeLocationValidation && workLocationValidation
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
    
    class func set(city: String) {
        cityConfiguration = city
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
    
    class private var cityConfiguration: String {
        set {
            UserDefaults.standard.set(newValue, forKey: "city")
            city.value = newValue
        }
        get {
            return UserDefaults.standard.string(forKey: "city") ?? ""
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
