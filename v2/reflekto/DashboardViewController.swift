/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  DashboardViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DashboardViewController: BaseViewController {
    
    override class func storyboardName() -> String? {
        return "Dashboard"
    }
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var statusBackground: UIView!
    @IBOutlet weak var statusText: UILabel!
    @IBOutlet weak var turnOffButton: UIButton!
    @IBOutlet weak var turnOnButton: UIButton!
    @IBOutlet weak var setupButton: UIButton!
    
    override func initializeView() {
        turnOnButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                isBackgroundModeEnabled = true
                self.updateBluetoothManagerStatus()
            })
            
        .addDisposableTo(disposeBag)
        
        turnOffButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                isBackgroundModeEnabled = false
                self.appDelegate.bluetoothManager = nil
                self.updateBluetoothManagerStatus()
            })
        .addDisposableTo(disposeBag)
        
        setupButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToSetup()
            })
        .addDisposableTo(disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        helloLabel.text = "Hello, \(Configuration.name.value)"
        updateBluetoothManagerStatus()
    }
    
    private func updateBluetoothManagerStatus() {
        changeStatusTo(turnedOn: isBackgroundModeEnabled)
    }
    
    private func navigateToSetup() {
        navigationController?.presentModallyNavigationVCWithViewController(withVCType: SetupInfoViewController.self, animated: true, popCurrentFromStack: true)
    }
    
    private func changeStatusTo(turnedOn isTurnedOn: Bool) {
        statusBackground.backgroundColor = isTurnedOn ? .refGreen : .refRed
        statusText.text = isTurnedOn ? "Working" : "Not working"
    }

}
