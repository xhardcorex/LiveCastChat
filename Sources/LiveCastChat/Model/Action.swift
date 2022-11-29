//
//  Action.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 16.02.2022.
//

import UIKit

struct Action {
    var target: Any?
    var selector: Selector? = nil
    var title: String? = nil
    var style: UIAlertAction.Style? = nil
    var handler: (() -> Void)? = nil
}
