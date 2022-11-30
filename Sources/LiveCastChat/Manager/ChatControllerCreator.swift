//
//  ChatControllerCreator.swift
//  
//
//  Created by Nik on 30.11.2022.
//

import Foundation

open class ChatControllerCreator {
    func chatListController() -> ChatListViewController {
        return ChatListViewController.instantiate(from: .chat)
    }
}
