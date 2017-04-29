//
//  SetupWorkLocationViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import MapKit

class SetupWorkLocationViewController: SetupViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    
    override func initializeView() {
        Configuration.workLocation.asObservable()
            .subscribe(onNext: { [unowned self] (longitude, latitude) in
                if longitude != 0 && latitude != 0 {
                    let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(latitude, longitude), 900, 900)
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
                Configuration.set(workLocation: Location(lon: longitude, lat: latitude))
                self.navigateToNextVC()
            })
        .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupSummaryViewController.self, popCurrentFromStack: false)
    }

}
