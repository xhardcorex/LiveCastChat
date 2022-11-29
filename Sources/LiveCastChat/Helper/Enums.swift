//
//  Enums.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 18.03.2022.
//

import UIKit

enum TextfieldState {
    case normal
    case error
}

enum Storyboard: String {
    case auth = "Main"
    case home = "Home"
    case setiings = "Settings"
    case room = "Room"
    case chat = "Chat"

    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T: UIViewController>(viewControllerClass: T.Type) -> T {
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            fatalError("ViewController \"\(storyboardID)\" not found in \"\(self.rawValue)\" storyboard.")
        }
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        return instance.instantiateInitialViewController()
    }
}
