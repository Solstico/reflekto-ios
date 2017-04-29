//
//  SetupSummaryViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

class SetupSummaryViewController: SetupViewController {

    @IBOutlet weak var startButton: UIButton!
    
    override func initializeView() {
        startButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToDashboard()
            })
        .addDisposableTo(disposeBag)
    }
    
    private func navigateToDashboard() {
        print("The end")
    }

}
