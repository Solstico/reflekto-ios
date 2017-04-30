//
//  DataManager.swift
//  reflekto
//
//  Created by Michał Kwiecień on 30.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import RxSwift
import UIKit
import EventKit

enum DataManagerError: Error {
    case jsonError
    case apiError
    case eventKitError
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
                    observer.onError(DataManagerError.apiError)
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
                    observer.onError(DataManagerError.jsonError)
                }
            }
        }
        task.resume()
        return Disposables.create {
            task.cancel()
        }
    }
    
    static let nextEvent: Observable<String> = Observable<String>.create { observer in
        let eventService = EventManager()
        guard let event = eventService.getNextEvent() else {
            observer.onError(DataManagerError.eventKitError)
            return Disposables.create { }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = event.timeZone
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        observer.onNext("\(dateFormatter.string(from: event.startDate)) - \(event.title)")
        return Disposables.create { }
    }
    
}
