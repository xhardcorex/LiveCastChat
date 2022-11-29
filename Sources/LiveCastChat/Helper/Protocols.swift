//
//  Protocols.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 15.02.2022.
//

import UIKit

@objc protocol Darkable: AnyObject {
    @objc optional var shouldDarkenBackground: Bool { get }
    @objc optional var viewToDarken: UIView? { get }
    @objc optional var darkeningAnimationDuration: CFTimeInterval { get }
}

protocol ErrorDisplayingInput: AnyObject {
    var state: TextfieldState { get set }
    var validationKey: String { get set }
    func set(errorText: String)
}

@objc protocol InterfaceLanguage {
    @objc optional func refreshLocalization()
}
