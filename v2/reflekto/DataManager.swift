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
import MapKit

enum DataManagerError: Error {
    case jsonError
    case apiError
    case eventKitError
    case wtfError
}

class DataManager {
    
    private static let gmailManager = GmailManager()
    
    static let timestamp: Observable<Int> = Observable<Int>.create { observer in
        let date = Date()
        let timestamp = Int(date.timeIntervalSince1970)
        let timestampWithTimezone = timestamp + TimeZone.current.secondsFromGMT()
        observer.onNext(timestampWithTimezone)
        observer.onCompleted()
        return Disposables.create { }
    }
    
    static let weather: Observable<Weather> = Observable<Weather>.create { observer in
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
                    observer.onNext(Weather(city: "", wind: "", additionalInfo: ""))
                    observer.onCompleted()
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
                        let weatherObject = Weather(city: string1, wind: string2, additionalInfo: string3)
                        observer.onNext(weatherObject)
                        observer.onCompleted()
                    }
                } catch {
                    observer.onNext(Weather(city: "", wind: "", additionalInfo: ""))
                    observer.onCompleted()
                }
            }
        }
        task.resume()
        return Disposables.create {
            task.cancel()
        }
    }
    
    static let nextEvent: Observable<String> = Observable<String>.create { observer in
        let eventStore = EKEventStore()
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = +7
        
        let endDay = calendar.date(byAdding: dateComponents, to: Date())!
        let startDay = Date()
        
        let predicate = eventStore.predicateForEvents(withStart: startDay, end: endDay, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        guard let event = events.first else {
            observer.onNext("")
            observer.onCompleted()
            return Disposables.create { }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.timeZone = event.timeZone
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        observer.onNext("\(dateFormatter.string(from: event.startDate)) - \(event.title)")
        observer.onCompleted()
        return Disposables.create { }
    }
    
    static let name: Observable<String> = Observable<String>.create { observer in
        let name = Configuration.name.value
        observer.onNext(name)
        observer.onCompleted()
        return Disposables.create { }
    }
    
    static let greeting: Observable<String> = Observable<String>.create { observer in
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 4...12:
            observer.onNext("Good morning")
        case 13...18:
            observer.onNext("Good afternoon")
        case 19...21:
            observer.onNext("Good evening")
        case 22...24:
            observer.onNext("Good night")
        case 0...3:
            observer.onNext("Good night")
        default:
            observer.onNext("")
            observer.onCompleted()
        }
        observer.onCompleted()
        return Disposables.create { }
    }
    
    static let compliment: Observable<String> = Observable<String>.create { observer in
        let compliments = ["Your smile is contagious", "You look great today",
                           "You're a smart cookie", "On a scale from 1 to 10, you're an 11",
                           "You have impeccable manners", "You should be proud of yourself",
                           "You're like sunshine on a rainy day", "Your hair looks stunning",
                           "You're gorgeous", "You're amazing",
                           ]
        let randomNumber = Int(arc4random_uniform(10))
        observer.onNext(compliments[randomNumber])
        observer.onCompleted()
        return Disposables.create { }
    }
    
    static let unreadMailsCount: Observable<Int> = Observable<Int>.create { observer in
        DataManager.gmailManager.unreadEmailsCountResponse = { unreadEmailsCount in
            observer.onNext(unreadEmailsCount)
            observer.onCompleted()
        }
        DataManager.gmailManager.getUnreadMails()
        return Disposables.create { }
    }
    
    static let travelToWorkTime: Observable<Int> = Observable<Int>.create { observer in //in minutes
        let homeLocationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude:  Configuration.homeLocation.value.lat, longitude:  Configuration.homeLocation.value.lon))
        let workLocationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude:  Configuration.workLocation.value.lat, longitude:  Configuration.workLocation.value.lon))
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: homeLocationPlacemark)
        request.destination = MKMapItem(placemark: workLocationPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculateETA(completionHandler: { (response, error) in
            guard error == nil, let response = response else { return }
            observer.onNext(Int(response.expectedTravelTime/60))
            observer.onCompleted()
        })
        return Disposables.create {
            directions.cancel()
        }
    }
    
}
