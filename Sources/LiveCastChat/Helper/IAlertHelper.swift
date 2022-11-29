//
//  IAlertHelper.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 16.02.2022.
//

import UIKit

protocol IAlertHelper: AnyObject {
    
}

extension IAlertHelper {
    func presentAlert(style: UIAlertController.Style? = nil, title: String? = nil, message: String? = nil, actions: [Action], completion: (() -> Void)? = nil) {
        let defaultStyle: UIAlertController.Style = actions.count > 2 ? .actionSheet : .alert
        var style = style ?? defaultStyle
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            style = .alert
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        
        let alertActions = actions.map { (action) -> UIAlertAction in
            return UIAlertAction(title: action.title, style: action.style ?? .default, handler: { _ in action.handler?() })
        }
        
        alertActions.forEach { alert.addAction($0) }
        present(alert, animated: true)
    }
    
    func presentErrorAlert(_ error: Error?, title: String? = nil) {
        guard let uError = error else { return }
        let error = uError as NSError
        let errorMessage = error.localizedDescription
        
        presentAlert(title: title, message: "\(errorMessage)", actions: [Action(title: "OK", handler: nil)], completion: nil)
    }
    
    func presentOkAlert(_ title: String? = nil, _ message: String? = nil) {
        presentAlert(title: title, message: message, actions: [Action(title: "OK", handler: nil)], completion: nil)
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        if let viewController = self as? UIViewController {
            DispatchQueue.main.async {
                viewController.present(viewControllerToPresent, animated: flag)
            }
        }
    }
}
