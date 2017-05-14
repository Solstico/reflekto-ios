//
//  Enums.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation

enum Sex: Int {
    case notSet
    case male
    case female
}

enum WeatherIcon: Int {
    case clearDay = 1
    case clearNight
    case rain
    case snow
    case sleet
    case wind
    case fog
    case cloude
    case partlyCloudyDay
    case partlyCloudyNight
    
    init(fromDarkskyApiIcon text: String) {
        switch text {
        case "clear-day":
            self.init(rawValue: 1)!
        case "clear-night":
            self.init(rawValue: 2)!
        case "rain":
            self.init(rawValue: 3)!
        case "snow":
            self.init(rawValue: 4)!
        case "sleet":
            self.init(rawValue: 5)!
        case "wind":
            self.init(rawValue: 6)!
        case "fog":
            self.init(rawValue: 7)!
        case "cloudy":
            self.init(rawValue: 8)!
        case "partly-cloudy-day":
            self.init(rawValue: 9)!
        case "partly-cloudy-night":
            self.init(rawValue: 10)!
        default:
            self.init(rawValue: 9)!
        }
    }
}
