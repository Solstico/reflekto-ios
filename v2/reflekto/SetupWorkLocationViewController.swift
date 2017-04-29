//
//  SetupWorkLocationViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

class SetupWorkLocationViewController: SetupViewController {

    @IBOutlet weak var nextButton: UIButton!
    
    override func initializeView() {
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToNextVC()
            })
        .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupSummaryViewController.self, popCurrentFromStack: false)
    }

}
