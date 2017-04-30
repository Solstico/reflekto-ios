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
    
    @IBOutlet weak var setupButton: UIButton!
    
    override func initializeView() {
        setupButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToSetup()
            })
            .addDisposableTo(disposeBag)
    }
    
    private func navigateToSetup() {
        navigationController?.presentModallyNavigationVCWithViewController(withVCType: SetupInfoViewController.self, animated: true, popCurrentFromStack: true)
    }

}
