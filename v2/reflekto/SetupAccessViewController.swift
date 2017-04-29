//
//  SetupAccessViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

class SetupAccessViewController: SetupViewController {

    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!

    override func initializeView() {
        locationButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToNextVC()
            })
            .addDisposableTo(disposeBag)
        locationButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToNextVC()
            })
            .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupHomeLocationViewController.self, popCurrentFromStack: false)
    }
    
}
