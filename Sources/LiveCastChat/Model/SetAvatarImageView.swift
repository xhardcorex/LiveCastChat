//
//  SetAvatarImageView.swift
//  LiveCast
//
//  Created by Игорь on 12.0122..
//

import UIKit

class AvatarImageView: UIImageView, UXImageViewStyle {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
}

protocol UXImageViewStyle {
    func applyStyle()
}

extension UXImageViewStyle where Self: UIImageView {
    func applyStyle() {
        layer.cornerRadius = self.bounds.height / 2.0
    }
}
