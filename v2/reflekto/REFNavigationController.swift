/*
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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
