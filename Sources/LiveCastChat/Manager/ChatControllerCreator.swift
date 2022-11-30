//
//  ChatControllerCreator.swift
//  
//
//  Created by Nik on 30.11.2022.
//

import UIKit

open class ChatControllerCreator {
    public static func chatListController() -> ChatListViewController {
        return UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatListViewController") as! ChatListViewController //ChatListViewController.instantiate(from: .chat)
    }
}
