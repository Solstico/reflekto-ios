//
//  SetupNameViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

class SetupNameViewController: SetupViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func initializeView() {
        nameTextField.becomeFirstResponder()
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.navigateToNextVC()
            })
            .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupSexViewController.self, popCurrentFromStack: false)
    }


}
