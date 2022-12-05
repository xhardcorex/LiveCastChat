//
//  MediaMessageCell.swift
//  LiveCast
//
//  Created by Nik on 14.10.2022.
//

import UIKit

open class ChatMediaMessageCell: MediaMessageCell {
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            fatalError(MessageKitError.nilMessagesDisplayDelegate)
        }
        
        switch message.kind {
        case .photo(let mediaItem):
            if let url = mediaItem.url {
              //  imageView.af.setImage(withURL: url)
                playButtonView.isHidden = true
            }
        case .video(let mediaItem):
            if let url = mediaItem.url {
              //  imageView.af.setImage(withURL: url)
                playButtonView.isHidden = false
            }
        default:
            break
        }
        
        displayDelegate.configureMediaMessageImageView(imageView, for: message, at: indexPath, in: messagesCollectionView)
    }
    
}
