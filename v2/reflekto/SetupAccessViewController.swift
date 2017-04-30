//
//  SetupAccessViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import CoreLocation
import EventKit
import RxCocoa
import RxSwift

class SetupAccessViewController: SetupViewController {
    
    let locationManager = CLLocationManager()
    let eventManager = EKEventStore()

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    
    let calendarAccess = Variable<Bool>(EKEventStore.authorizationStatus(for: EKEntityType.event) == .authorized)

    override func initializeView() {
        locationButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.locationManager.requestWhenInUseAuthorization()
            })
        .addDisposableTo(disposeBag)
        
        calendarButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.eventManager.requestAccess(to: .event, completion: self.calendarAccessCompletionHandler)
            })
        .addDisposableTo(disposeBag)
        
        Observable.combineLatest(calendarAccess.asObservable(), locationManager.rx.didChangeAuthorizationStatus)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (calendarAccess, locationStatus) in
                self.locationButton.isEnabled = locationStatus != .authorizedWhenInUse
                self.calendarButton.isEnabled = !calendarAccess
                if calendarAccess && locationStatus == .authorizedWhenInUse {
                    self.navigateToNextVC()
                }
            })
            .addDisposableTo(disposeBag)
        
    }
    
    private lazy var calendarAccessCompletionHandler: (Bool, Error?) -> Void = { [unowned self] (hasAccess, _) in
        self.calendarAccess.value = hasAccess
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupHomeLocationViewController.self, popCurrentFromStack: true)
    }
    
}
