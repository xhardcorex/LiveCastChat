//
//  CustomMessagesFlowLayout.swift
//  LiveCast
//
//  Created by Nik on 01.06.2022.
//

import UIKit

open class CustomMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    lazy open var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)

    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        //before checking the messages check if section is reserved for typing otherwise it will cause IndexOutOfBounds error
        if isSectionReservedForTypingIndicator(indexPath.section) {
            return typingIndicatorSizeCalculator
        }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
}
