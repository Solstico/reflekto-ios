/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
        
        var urlComponents = URLComponents(string: "\(baseUrl)\(apiKey)/\(location.lat),\(location.lon)")!
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
                        let temperatureC = Int((json["currently"] as! [String: Any])["temperature"] as! NSNumber)
                        let windSpeed = Int((json["currently"] as! [String: Any])["windSpeed"] as! NSNumber)
                        let summary = (json["hourly"] as! [String: Any])["summary"] as! String
                        let icon = WeatherIcon.init(fromDarkskyApiIcon: ((json["currently"] as! [String: Any])["icon"] as! String))

                        let string1 = "\(Configuration.city.value), \(temperatureC)C\(icon.rawValue)"
                        let string2 = "Wind: \(windSpeed) m/s"
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
        
        observer.onNext("\(dateFormatter.string(from: event.startDate))\n\(event.title)")
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
        let femaleCompliments = ["You look strong today", "You're a smart cookie", "I believe in you", "Your hair looks stunning", "You are so pretty", "I respect you", "You have a beautiful smile", "I love your voice", "You smell magnificent", "You are the strongest woman", "You are the toughest woman", "I love your eyes", "You are so beautiful", "Your skin look great!", "I'm so proud of you", "I like your style", "What would I do without you?", "I love the way you look at me", "You are an amazing person", "You look great today", "You're gorgeous"]
        let maleCompliments = ["You look strong today", "You look so handsome", "I believe in you", "You look extra manly today", "You’re the strongest man", "I respect you", "You have a beautiful smile", "I love your deep voice", "You smell magnificent", "You are the strongest man", "You are the toughest man", "I love your eyes", "You are so handy!", "Your arms look great!", "I'm so proud of you", "I like your style", "What would I do without you?", "You are the perfect height", "You are an amazing person", "You look great today", "You're gorgeous"]
        
        let randomNumber = Int(arc4random_uniform(UInt32(femaleCompliments.count)))
        let sex = Configuration.sex.value
        observer.onNext(sex == .male ? maleCompliments[randomNumber] : femaleCompliments[randomNumber])
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
