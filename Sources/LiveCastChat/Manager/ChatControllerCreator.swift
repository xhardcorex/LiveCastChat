//
//  ChatControllerCreator.swift
//  
//
//  Created by Nik on 30.11.2022.
//

import UIKit

open class ChatControllerCreator {
    public static func chatListController() -> ChatListViewController {
        return ChatListViewController.instantiate(from: .chat)
    }
}
