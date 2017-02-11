//
//  DataInteractor.swift
//  reflekto
//
//  Created by Michał Kwiecień on 11.02.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import UIKit

typealias InteractorSuccess = (String) -> ()
typealias InteractorFailure = (Error) -> ()

class DataInteractor {
    
    class func getTime(success: InteractorSuccess, failure: InteractorFailure) {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        success(dateFormatter.string(from: date))
    }
    
    class func getWeather(success: @escaping InteractorSuccess, failure: @escaping InteractorFailure) {
        LocationInteractor.getLocation(success: { (lon, lat, city) in
            WeatherAPI.getWeather(lon: lon, lat: lat, success: { response in
                guard let json = response as? [String : Any] else {
                    failure(NSError(domain: "API Error", code: -1, userInfo: nil))
                    return
                }
                let temperatureF = (json["currently"] as! [String: Any])["temperature"] as! Double
                let temperatureC = Int((temperatureF - 32) / 1.8)
                success("\(city), \(temperatureC)°C")
                
            }) { error in
                failure(error)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    class func getName(success: InteractorSuccess, failure: InteractorFailure) {
        let deviceName = UIDevice.current.name
        let array = deviceName.components(separatedBy: " ")
        if let name = array.first {
            success(name)
        } else {
            failure(NSError(domain: "Name error", code: -1, userInfo: nil))
        }
    }
    
    class func getSex(success: InteractorSuccess, failure: InteractorFailure) {
        DataInteractor.getName(success: { value in
            let lastChar = value[value.index(before: value.endIndex)]
            if lastChar == "a" {
                success("Kobieta")
            } else {
                success("Mężczyzna")
            }
        }) { error in
            failure(NSError(domain: "Name error", code: -1, userInfo: nil))
        }
    }
    
    class func getWeatherAdditional(success: @escaping InteractorSuccess, failure: @escaping InteractorFailure) {
        LocationInteractor.getLocation(success: { (lon, lat, city) in
            WeatherAPI.getWeather(lon: lon, lat: lat, success: { response in
                guard let json = response as? [String : Any] else {
                    failure(NSError(domain: "API Error", code: -1, userInfo: nil))
                    return
                }
                let windSpeed = (json["currently"] as! [String: Any])["windSpeed"] as! Int
                success("Wiatr: \(windSpeed) km/h")
                
            }) { error in
                failure(error)
            }
        }) { (error) in
            failure(error)
        }
    }
    
    class func getWeatherAdvice(success: @escaping InteractorSuccess, failure: @escaping InteractorFailure) {
        LocationInteractor.getLocation(success: { (lon, lat, city) in
            WeatherAPI.getWeather(lon: lon, lat: lat, success: { response in
                guard let json = response as? [String : Any] else {
                    failure(NSError(domain: "API Error", code: -1, userInfo: nil))
                    return
                }
                let summary = (json["hourly"] as! [String: Any])["summary"] as! String
                success(summary)
                
            }) { error in
                failure(error)
            }
        }) { (error) in
            failure(error)
        }
    }
    
}
