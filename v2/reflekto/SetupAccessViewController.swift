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
import GoogleSignIn
import GoogleAPIClientForREST

class SetupAccessViewController: SetupViewController {
    
    fileprivate let service = GTLRGmailService()
    
    let locationManager = CLLocationManager()
    let eventManager = EKEventStore()

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    let calendarAccess = Variable<Bool>(EKEventStore.authorizationStatus(for: EKEntityType.event) == .authorized)
    let gmailAccess = Variable<Bool>(GIDSignIn.sharedInstance().hasAuthInKeychain())

    override func initializeView() {
        setupGoogleServices()
        
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
        
        Observable.combineLatest(calendarAccess.asObservable(), locationManager.rx.didChangeAuthorizationStatus, gmailAccess.asObservable())
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (calendarAccess, locationStatus, gmailAccess) in
                self.locationButton.isEnabled = locationStatus != .authorizedWhenInUse
                self.calendarButton.isEnabled = !calendarAccess
                self.signInButton.isEnabled = !gmailAccess
                if calendarAccess && locationStatus == .authorizedWhenInUse && gmailAccess  {
                    self.navigateToNextVC()
                }
            })
            .addDisposableTo(disposeBag)
    }
    
    private func setupGoogleServices() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = [kGTLRAuthScopeGmailReadonly]
        GIDSignIn.sharedInstance().signInSilently()
    }
    
    private lazy var calendarAccessCompletionHandler: (Bool, Error?) -> Void = { [unowned self] (hasAccess, _) in
        self.calendarAccess.value = hasAccess
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupHomeLocationViewController.self, popCurrentFromStack: true)
    }
    
}

extension SetupAccessViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let _ = error {
            self.service.authorizer = nil
        } else {
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            self.gmailAccess.value = true
        }
    }
    
}
