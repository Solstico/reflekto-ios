//
//  WeatherAPI.swift
//  reflekto
//
//  Created by Michał Kwiecień on 11.02.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation

typealias ApiSuccess = (Any) -> ()
typealias ApiFailure = (Error) -> ()

class WeatherAPI {
    
    private static let apiKey = "2583095ca832807147ba1ffe3cac5286"
    private static let baseUrl = "https://api.darksky.net/forecast/"
    
    class func getWeather(lon: Double, lat: Double, success: @escaping ApiSuccess, failure: @escaping ApiFailure) {
        let session = URLSession.shared
        
        var urlComponents = URLComponents(string: "\(baseUrl)\(apiKey)/\(lon),\(lat)")!
        urlComponents.queryItems = [
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "units", value: "ca"),
            URLQueryItem(name: "exclude", value: "minutely, daily, alerts, flags"),
        ]
        
        let task = session.dataTask(with: urlComponents.url! as URL) { (data, response, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    failure(error!)
                    return
                }
                do {
                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] {
                        success(json)
                    }
                } catch {
                    failure(NSError(domain: "JSON error", code: -1, userInfo: nil))
                }
            }
        }
        task.resume()
    }
    
}

