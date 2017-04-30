//
//  DataManager.swift
//  reflekto
//
//  Created by Michał Kwiecień on 30.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import RxSwift

enum ApiError: Error {
    case jsonError
    case apiError
}

class DataManager {
    
    static let timestamp: Observable<Int> = Observable<Int>.create { observer in
        let date = Date()
        let timestamp = Int(date.timeIntervalSince1970)
        observer.onNext(timestamp)
        observer.onCompleted()
        return Disposables.create { }
    }
    
    static let weather: Observable<String> = Observable<String>.create { observer in
        let apiKey = "2583095ca832807147ba1ffe3cac5286"
        let baseUrl = "https://api.darksky.net/forecast/"
        let location = Configuration.homeLocation.value
        
        var urlComponents = URLComponents(string: "\(baseUrl)\(apiKey)/\(location.lon),\(location.lat)")!
        urlComponents.queryItems = [
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "units", value: "auto"),
            URLQueryItem(name: "exclude", value: "minutely, daily, alerts, flags"),
        ]
        let session = URLSession.shared
        let task = session.dataTask(with: urlComponents.url! as URL) { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    observer.onError(ApiError.apiError)
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        let temperatureF = (json["currently"] as! [String: Any])["temperature"] as! Double
                        let windSpeed = (json["currently"] as! [String: Any])["windSpeed"] as! Int
                        let summary = (json["hourly"] as! [String: Any])["summary"] as! String
                        let temperatureC = Int((temperatureF - 32) / 1.8)

                        let string1 = "\(Configuration.city.value), \(temperatureC)°C"
                        let string2 = "Wind: \(windSpeed) km/h"
                        let string3 = "\(summary)"
                        observer.onNext("\(string1)---\(string2)---\(string3)")
                    }
                } catch {
                    observer.onError(ApiError.jsonError)
                }
            }
        }
        task.resume()
        return Disposables.create {
            task.cancel()
        }
    }
    
}
