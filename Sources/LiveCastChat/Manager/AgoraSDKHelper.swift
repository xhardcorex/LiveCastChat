//
//  AgoraSDKHelper.swift
//  LiveCast
//
//  Created by Vitalii on 28.04.2022.
//

import Foundation
import AgoraChat
import AVFoundation

enum CmdMessageAction: String {
    case typing = "MSG_TYPING_BEGIN"
    case stop = "MSG_TYPING_END"
    case updatedReaction = "MSG_UPDATED_REACTION"
}

class AgoraSDKHelper {
    
    private init() {}

    class func initMessage(_ text: String?,
                         to receiver: String?,
                         chatType: AgoraChatType,
                          messageExt: [AnyHashable : Any]?) -> AgoraChatMessage? {
        let body = AgoraChatTextMessageBody(text: text)

        let sender = AgoraChatClient.shared().currentUsername
        let message = AgoraChatMessage(conversationID: receiver ?? "-",
                                       from: sender ?? "-",
                                       to: receiver ?? "-",
                                       body: body,
                                       ext: messageExt)
        message.chatType = chatType
        return message
    }
    
    class func initImageMessage(_ image: UIImage?,
                              to receiver: String?,
                              chatType: AgoraChatType,
                              messageExt: [AnyHashable : Any]?) -> AgoraChatMessage? {
        
        guard let data = image?.jpegData(compressionQuality: 1.0) else { return nil }
        let body = AgoraChatImageMessageBody(data: data, displayName: UUID().uuidString)

        let sender = AgoraChatClient.shared().currentUsername
        let message = AgoraChatMessage(conversationID: receiver ?? "-",
                                       from: sender ?? "-",
                                       to: receiver ?? "-",
                                       body: body,
                                       ext: messageExt)
        message.chatType = chatType
        return message
    }
    
    class func initVideoMessage(_ url: URL?,
                              to receiver: String?,
                              chatType: AgoraChatType,
                              messageExt: [AnyHashable : Any]?) -> AgoraChatMessage? {
        guard let url = url else { return nil}
        let body = AgoraChatVideoMessageBody(localPath: url.path, displayName: "movie.mp4")
        let asset = AVURLAsset(url: url)
        let durationInSeconds = asset.duration.seconds
        print(durationInSeconds)
        body.duration = Int32(durationInSeconds)
        let sender = AgoraChatClient.shared().currentUsername
        let message = AgoraChatMessage(conversationID: receiver ?? "-",
                                       from: sender ?? "-",
                                       to: receiver ?? "-",
                                       body: body,
                                       ext: messageExt)
        message.chatType = chatType
        return message

    }
    
    class func initCmdMessage(_ text: String?,
                         to receiver: String?,
                         chatType: AgoraChatType,
                         action: CmdMessageAction,
                         messageExt: [AnyHashable : Any]?) -> AgoraChatMessage? {
        let body = AgoraChatCmdMessageBody(action: action.rawValue)
        let sender = AgoraChatClient.shared().currentUsername
        let message = AgoraChatMessage(conversationID: receiver ?? "-",
                                       from: sender ?? "-",
                                       to: receiver ?? "-",
                                       body: body,
                                       ext: messageExt)
        message.chatType = chatType
        return message
    }
    
}

