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

enum WeatherIcon: String {
    case clearDay = "1"
    case clearNight = "2"
    case rain = "3"
    case snow = "4"
    case sleet = "5"
    case wind = "6"
    case fog = "7"
    case cloudy = "8"
    case partlyCloudyDay = "9"
    case partlyCloudyNight  = ":"
    
    init(fromDarkskyApiIcon text: String) {
        switch text {
        case "clear-day":
            self = .clearDay
        case "clear-night":
            self = .clearNight
        case "rain":
            self = .rain
        case "snow":
            self = .snow
        case "sleet":
            self = .sleet
        case "wind":
            self = .wind
        case "fog":
            self = .fog
        case "cloudy":
            self = .cloudy
        case "partly-cloudy-day":
            self = .partlyCloudyDay
        case "partly-cloudy-night":
            self = .partlyCloudyNight
        default:
            self = .partlyCloudyDay
        }
    }
    
}
