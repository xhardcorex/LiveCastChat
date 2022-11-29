//
//  UIViewController+Extensions.swift
//  LiveCast
//
//  Created by Игорь on 22.1221..
//

import UIKit

// MARK: - UIViewController extension

extension UIViewController {
    // Please note that View Controller id should be the same as its class name
    class var storyboardID: String {
        return "\(self)"
    }
    
    static func instantiate(from storyboard: Storyboard) -> Self {
        return storyboard.viewController(viewControllerClass: self)
    }
    
    func makeLargeTitle(with tableView: UITableView?) {
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.sizeToFit()
        tableView?.contentInsetAdjustmentBehavior = .never
    }
}
