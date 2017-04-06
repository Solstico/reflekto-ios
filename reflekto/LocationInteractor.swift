//
//  LocationInteractor.swift
//  reflekto
//
//  Created by Michał Kwiecień on 11.02.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import Foundation
import CoreLocation

class LocationInteractor {
    
    class func getLocation(success: @escaping (Double, Double, String) -> (), failure: InteractorFailure) {
        let locManager = CLLocationManager()
        guard CLLocationManager.authorizationStatus() == .authorizedAlways else { return }
        var currentLocation: CLLocation!
    
        currentLocation = locManager.location
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { (placemark, _) in
            if let city = placemark?.first?.locality {
                success(currentLocation.coordinate.longitude, currentLocation.coordinate.latitude, city)
            }
        }
    }
    
}
