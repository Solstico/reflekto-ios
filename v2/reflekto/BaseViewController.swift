/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  ViewController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BaseViewController: UIViewController {
    
    @IBInspectable var showAnyLeftBarButton: Bool = true
    var suppliedInitData: Any?
    
    let disposeBag = DisposeBag()
    
    override var navigationController: REFNavigationController? {
        get {
            return super.navigationController as? REFNavigationController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeView()
        localize()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowSelector), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideSelector), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareNavigationItem()
    }
    
    /// Override and configure views in this method (bind presenter, setup rx)
    internal func initializeView() { }
    
    /// Override and localize static texts in this method
    internal func localize() { }
    
    //MARK: View setup helpers
    func prepareNavigationItem() {
        guard showAnyLeftBarButton else {
            navigationItem.setLeftBarButton(UIBarButtonItem(customView: UIView()), animated: false)
            return
        }
    }
    
    //MARK: Keyboard notifications helpers
    @objc private func keyboardWillShowSelector(notification:NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        let height = keyboardFrame.size.height
        keyboardWillShowWith(height: height)
    }
    
    @objc private func keyboardWillHideSelector(notification:NSNotification) {
        keyboardWillHide()
    }
    
    
    /// Override to do view adjustments when keyboard is showing
    ///
    /// - Parameter height: keyboard height
    func keyboardWillShowWith(height: CGFloat) {}
    
    /// Override to do view adjustemns when keyboard is hiding
    func keyboardWillHide() {}
    
    //MARK: Popup helpers
    func showAlert(withMessage message: String?, title: String? = "", buttonTitle: String? = "OK", onTap: ((Void) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: buttonTitle, style: .default, handler: { alertAction in
            onTap?()
        })
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: Instantiate helpers
    class func storyboardName() -> String? {
        return nil
    }
    
    class func instantiate() -> BaseViewController? {
        guard let storyboardName = storyboardName() else {
            return nil
        }
        let storyboard = UIStoryboard(name: storyboardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as? BaseViewController
    }

}

