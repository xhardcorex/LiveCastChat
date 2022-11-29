//
//  GifMessageCell.swift
//  LiveCast
//
//  Created by Nik on 27.05.2022.
//

import UIKit
import SwiftyGif 

open class GifMessageCell: MessageContentCell {
    var gifImageView: UIImageView?
    
    open override func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        self.contentView.backgroundColor = UIColor.white
        gifImageView?.removeFromSuperview()
        let messageExtension = message.kind
        
        if case let .custom(ext) = messageExtension {
            guard let gifExtension = ext as? GifAttachment,
                  let gifUrl = URL(string: gifExtension.gifUrl) else { return }
            gifImageView = UIImageView(gifURL: gifUrl)
            messageContainerView.addSubview(gifImageView!)
            self.gifImageView?.frame = messageContainerView.bounds
        }
    }
}
