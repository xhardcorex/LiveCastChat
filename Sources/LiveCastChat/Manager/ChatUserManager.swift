//
//  ChatUserManager.swift
//  LiveCast
//
//  Created by Nik on 08.11.2022.
//

import Foundation
import AgoraChat

open class ChatUserManager {
    
    public static let shared = ChatUserManager()

    public func updateCurrentUserAvatar(with url: String) {
        AgoraChatClient.shared().userInfoManager.updateOwnUserInfo(url, with: .avatarURL)
    }
    
}
