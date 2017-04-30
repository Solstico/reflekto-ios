//
//  SetupInfoViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SetupInfoViewController: SetupViewController {

    @IBOutlet weak var goButton: UIButton!
    
    override func initializeView() {
        goButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToNextVC()
            })
        .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupNameViewController.self, popCurrentFromStack: true)
    }

}
