//
//  RENavigationController.swift
//  reflekto
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

class REFNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Instantiate helpers
    class func storyboardName() -> String? {
        return nil
    }
    
    class func instantiate(withRootVC rootVc: BaseViewController) -> REFNavigationController {
        return REFNavigationController(rootViewController: rootVc)
    }
    
    //MARK: Navigation helpers
    func presentModallyViewController<T: BaseViewController>(withType vcType: T.Type, animated: Bool, suppliedData: Any? = nil) {
        guard let vc = vcType.instantiate() else { return }
        vc.suppliedInitData = suppliedData
        present(vc, animated: animated)
    }
    
    func presentModallyNavigationVCWithViewController<T: BaseViewController>(withVCType vcType: T.Type, animated: Bool, popCurrentFromStack: Bool, suppliedData: Any? = nil) {
        guard let vc = vcType.instantiate() else { return }
        vc.suppliedInitData = suppliedData
        let navVC = REFNavigationController.instantiate(withRootVC: vc)
        if !popCurrentFromStack {
            present(navVC, animated: animated)
        } else {
            UIApplication.shared.keyWindow?.replaceRootViewControllerWith(navVC, animated: animated)
        }
    }
    
    func navigateToViewController<T: BaseViewController>(withType vcType: T.Type, popCurrentFromStack: Bool, suppliedData: Any? = nil) {
        let vcIndex = indexOfViewController(withType: vcType)
        if let index = vcIndex, let vc = viewControllers[index] as? BaseViewController {
            vc.suppliedInitData = suppliedData
            popToViewController(vc, animated: true)
        } else if let newViewController = vcType.instantiate() {
            newViewController.suppliedInitData = suppliedData
            if !popCurrentFromStack {
                pushViewController(newViewController, animated: true)
            } else {
                var vcStack = viewControllers
                vcStack.removeLast()
                vcStack.append(newViewController)
                setViewControllers(vcStack, animated: true)
            }
        }
    }
    
    private func indexOfViewController<T: BaseViewController>(withType vcType: T.Type) -> Int? {
        var vcIndex: Int?
        for i in 0..<viewControllers.count {
            if viewControllers[i].isKind(of: vcType) {
                vcIndex = i
                break
            }
        }
        return vcIndex
    }
}
