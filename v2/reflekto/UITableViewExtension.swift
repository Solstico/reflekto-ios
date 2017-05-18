//
//  UITableViewExtension.swift
//  ios-vrl
//
//  Created by Michał Kwiecień on 29.04.2017.
//  Copyright © 2017 Solstico. All rights reserved.
//

import UIKit

extension UITableView {
    
    func registerCell(name: String?) {
        guard let name = name else {
            return
        }
        register(UINib(nibName: name, bundle: Bundle.main), forCellReuseIdentifier: name)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: T.className, for: indexPath) as? T
    }
}
