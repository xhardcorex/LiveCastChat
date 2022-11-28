//
//  ChatUserManager.swift
//  LiveCast
//
//  Created by Nik on 08.11.2022.
//

import Foundation
import AgoraChat

class ChatUserManager {
    
    static let shared = ChatUserManager()

    func updateCurrentUserAvatar() {
        //FIXME: Add avatar
//        guard let urlString = UserManager.user.currentUser?.avatar?.presignedUrl else { return }
        AgoraChatClient.shared().userInfoManager.updateOwnUserInfo("", with: .avatarURL)
    }
    
}
