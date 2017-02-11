//
//  DataInteractor.swift
//  reflekto
//
//  Created by Michał Kwiecień on 11.02.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation

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
                
                let temperature = (json["currently"] as! [String: Any])["temperature"] as! Int
                
                success("\(city), \(temperature)°C")
            }) { error in
                failure(error)
            }
        }) { (error) in
            failure(error)
        }
        
    }
    
}
