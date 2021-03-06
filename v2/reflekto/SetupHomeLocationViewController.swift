/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  SetupHomeLocationViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class SetupHomeLocationViewController: SetupViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    override func initializeView() {
        Configuration.homeLocation.asObservable()
            .subscribe(onNext: { [unowned self] (longitude, latitude) in
                if longitude != 0 && latitude != 0 {
                    let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude), Defaults.mapScaleDistace, Defaults.mapScaleDistace)
                    self.mapView.region = region
                } else {
                    self.mapView.userTrackingMode = .follow
                }
            })
        .addDisposableTo(disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                let longitude = self.mapView.centerCoordinate.longitude
                let latitude = self.mapView.centerCoordinate.latitude
                Configuration.set(homeLocation: Location(lon: longitude, lat: latitude))
                
                let clLocation = CLLocation(latitude: latitude, longitude: longitude)
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(clLocation) { (placemark, _) in
                    if let city = placemark?.first?.locality {
                        Configuration.set(city: city)
                    }
                    self.navigateToNextVC()
                }
            })
        .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupWorkLocationViewController.self, popCurrentFromStack: false)
    }

}
