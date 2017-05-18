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
