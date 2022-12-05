//
//  ChatTextMessageCell.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 20.02.2022.
//

import UIKit

open class ChatTextMessageCell: TextMessageCell {
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let attributes = layoutAttributes as? MessagesCollectionViewLayoutAttributes {
            messageLabel.textInsets = attributes.messageLabelInsets
            messageLabel.textInsets.left = attributes.messageLabelInsets.left / 2
            messageLabel.textInsets.right = attributes.messageLabelInsets.right / 2
            
            switch attributes.avatarPosition.horizontal {
            case .cellLeading:
                messageLabel.textAlignment = .left
            case .cellTrailing:
                messageLabel.textAlignment = .right
            case .natural:
                break
            }
        }
    }
    
    open override func layoutAvatarView(with attributes: MessagesCollectionViewLayoutAttributes) {
        var origin: CGPoint = .zero
        let padding = attributes.avatarLeadingTrailingPadding
        
        switch attributes.avatarPosition.horizontal {
        case .cellLeading:
            origin.x = padding
        case .cellTrailing:
            origin.x = attributes.frame.width - attributes.avatarSize.width - padding
        case .natural:
            fatalError()
        }
        
        origin.y = messageTopLabel.frame.maxY / 2
        
        avatarView.frame = CGRect(origin: origin, size: attributes.avatarSize)
    }
    
}
