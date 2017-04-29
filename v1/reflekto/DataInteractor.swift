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
                success("Female")
            } else {
                success("Male")
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
                success("Wind: \(windSpeed) km/h")
                
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
    
    class func getNextEvent(success: @escaping InteractorSuccess, failure: @escaping InteractorFailure) {
        let eventService = EventService()
        guard let event = eventService.getNextEvent() else {
            failure(NSError(domain: "EventKit Error", code: -2, userInfo: nil))
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = event.timeZone
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        success("\(dateFormatter.string(from: event.startDate)) - \(event.title)")
    }
    
    class func getGreeting(success: InteractorSuccess, failure: InteractorFailure) {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 4...12:
            success("Good morning")
        case 13...18:
            success("Good afternoon")
        case 19...21:
            success("Good evening")
        case 22...24:
            success("Good night")
        case 0...3:
            success("Good night")
        default:
            break
        }
    }
    
    class func getCompliment(success: InteractorSuccess, failure: InteractorFailure) {
        let compliments = ["Your smile is contagious", "You look great today",
                           "You're a smart cookie", "On a scale from 1 to 10, you're an 11",
                           "You have impeccable manners", "You should be proud of yourself",
                           "You're like sunshine on a rainy day", "Your hair looks stunning",
                           "You're gorgeous", "You're amazing",
        ]
        let randomNumber = Int(arc4random_uniform(10))
        success(compliments[randomNumber])
    }
    
}
