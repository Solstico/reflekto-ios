//
//  BackgroundService.swift
//  reflekto
//
//  Created by Michał Kwiecień on 21.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation

class BackgroundService {
    
    var time: String?
    var weather: String?
    var name: String?
    var sex: String?
    var weatherAdditional: String?
    var weatherAdvice: String?
    var nextEvent: String?
    var greeting: String?
    var compliment: String?
    
    let dataNeededToDownload = 9
    var downloadedData = 0
    var dataPrepared: (() -> (Void))?
    
    func prepareAllData() {
        downloadedData = 0
        
        DataInteractor.getTime(success: { value in
            self.time = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getWeather(success: { value in
            self.weather = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getName(success: { value in
            self.name = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getSex(success: { value in
            self.sex = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getWeatherAdditional(success: { value in
            self.weatherAdditional = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getWeatherAdvice(success: { value in
            self.weatherAdvice = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getNextEvent(success: { value in
            self.nextEvent = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getGreeting(success: { value in
            self.greeting = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
        
        DataInteractor.getCompliment(success: { value in
            self.compliment = value
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }) { _ in
            self.downloadedData += 1
            self.invalidateDownloadedEleements()
        }
    }
    
    private func invalidateDownloadedEleements() {
        if downloadedData == dataNeededToDownload {
            print("All required data downloaded")
            dataPrepared?()
        }
    }
    
    
}
