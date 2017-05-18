//
//  SetupSexViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

class SetupSexViewController: SetupViewController {

    @IBOutlet weak var femaleButton: UIButton!
    @IBOutlet weak var notSureButton: UIButton!
    @IBOutlet weak var maleButton: UIButton!

    override func initializeView() {
        femaleButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                Configuration.set(sex: .female)
                self.navigateToNextVC()
            })
        .addDisposableTo(disposeBag)
        
        maleButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                Configuration.set(sex: .male)
                self.navigateToNextVC()
            })
        .addDisposableTo(disposeBag)
        
        notSureButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.showAlert(withMessage: "This app is not for you", title: "Sorry", buttonTitle: "Ehh, OK ;(")
            })
        .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupAccessViewController.self, popCurrentFromStack: false)
    }

}
