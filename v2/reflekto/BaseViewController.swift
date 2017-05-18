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

