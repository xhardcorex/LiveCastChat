//
//  CellIdentifiable.swift
//  LiveCast
//
//  Created by Игорь on 18.0122..
//

import Foundation

// MARK: - Auto Generated identifiers

protocol Identifiable: AnyObject {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String { "\(self)" }
}
