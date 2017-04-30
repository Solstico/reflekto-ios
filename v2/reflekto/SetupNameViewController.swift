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
        
        Configuration.name.asObservable()
            .bind(to: nameTextField.rx.text)
        .addDisposableTo(disposeBag)
        
        nextButton.rx.tap
            .subscribe(onNext: { [unowned self] in
                Configuration.set(name: self.nameTextField.text ?? "")
                self.navigateToNextVC()
            })
        .addDisposableTo(disposeBag)
    }
    
    private func navigateToNextVC() {
        navigationController?.navigateToViewController(withType: SetupSexViewController.self, popCurrentFromStack: false)
    }


}
