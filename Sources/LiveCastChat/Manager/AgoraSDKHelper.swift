//
//  AgoraSDKHelper.swift
//  LiveCast
//
//  Created by Vitalii on 28.04.2022.
//

import Foundation
import AgoraChat
import AVFoundation

public enum CmdMessageAction: String {
    case typing = "MSG_TYPING_BEGIN"
    case stop = "MSG_TYPING_END"
    case updatedReaction = "MSG_UPDATED_REACTION"
}

open class AgoraSDKHelper {
    
    private init() {}

    public class func initMessage(_ text: String?,
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
    
    public class func initImageMessage(_ image: UIImage?,
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
    
    public class func initVideoMessage(_ url: URL?,
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
    
    public class func initAudioMessage(_ url: URL?,
                              to receiver: String?,
                              chatType: AgoraChatType,
                              messageExt: [AnyHashable : Any]?) -> AgoraChatMessage? {
        
        guard let url = url else { return nil}
        let body = AgoraChatVoiceMessageBody(localPath: url.path, displayName: "audioMessage")
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
    
    public class func initCmdMessage(_ text: String?,
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
    
    public class func downloadSound(url: URL, completion: @escaping ((URL?) -> Void)) {
        guard let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let desURL = docUrl.appendingPathComponent("audiomessage.m4a")
        var downloadTask:URLSessionDownloadTask
            downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (URLData, response, error) -> Void in
                do {
                    let isFileFound = FileManager.default.fileExists(atPath: desURL.path)
                    if isFileFound == true {
                        print(desURL) //delete tmpsong.m4a & copy
                        try FileManager.default.removeItem(atPath: desURL.path)
                        try FileManager.default.copyItem(at: URLData!, to: desURL)
                    } else {
                        try FileManager.default.copyItem(at: URLData!, to: desURL)
                    }
                    completion(desURL)
                } catch let err {
                    print(err.localizedDescription)
                }
            })
            downloadTask.resume()
    }
    
}

