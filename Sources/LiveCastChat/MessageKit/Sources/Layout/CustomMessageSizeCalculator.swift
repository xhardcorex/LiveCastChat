//
//  CustomMessageSizeCalculator.swift
//  LiveCast
//
//  Created by Nik on 01.06.2022.
//

import UIKit

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
    // Customize this function implementation to size your content appropriately. This example simply returns a constant size
    // Refer to the default MessageKit cell implementations, and the Example App to see how to size a custom cell dynamically
        let messageExtension = message.kind
        if case let .custom(ext) = messageExtension {
            guard let gifExtension = ext as? GifAttachment else { return CGSize(width: 0, height: 0) }
            return CGSize(width: gifExtension.gifWidth, height: gifExtension.gifHeight)
        }

        return CGSize(width: 0, height: 0)
    }
}
