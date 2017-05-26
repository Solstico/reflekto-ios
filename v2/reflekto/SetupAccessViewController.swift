/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
