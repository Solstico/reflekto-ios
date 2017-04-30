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
