//
//  ChatReactionManager.swift
//  LiveCast
//
//  Created by Nik on 30.09.2022.
//

import Foundation
import AgoraChat

class ChatReactionManager {
  
    static let shared = ChatReactionManager()
    
    let reactionsDataset = [
          (imageName: "👍", reaction: "thumbs up"),
          (imageName: "👎", reaction: "thumbs down"),
          (imageName: "❤️", reaction: "red heart"),
          (imageName: "🔥", reaction: "fire"),
          (imageName: "🥰", reaction: "smiling face with hearts"),
          (imageName: "👏", reaction: "clapping hands"),
          (imageName: "😁", reaction: "grinning face")
      ]

    var reactions: [String : [AgoraChatMessageReaction]]?

    func reactionsFor(messageId: String) -> [String] {
        return reactions?.first(where: { $0.key == messageId })?.value.compactMap({ $0.reaction }).sorted(by: { $0 > $1 }) ?? []
    }

    func sendReaction(with index: Int, to messageId: String, completion: @escaping ReturnFlag) {
        if self.reactions?[messageId]?.first(where: { $0.reaction == reactionsDataset[index].reaction }) == nil {
            add(with: index, to: messageId) {
                completion(true)
            }
        } else {
            remove(with: index, to: messageId) {
                completion(false)
            }
        }
    }

    func add(with index: Int, to messageId: String, completion: @escaping ReturnAction) {
        AgoraChatClient.shared().chatManager.addReaction(reactionsDataset[index].reaction, toMessage: messageId, completion: { error in
            if let error = error {
                print(error.errorDescription!)
            }
            completion()
        })
    }

    func remove(with index: Int, to messageId: String, completion: @escaping ReturnAction) {
        AgoraChatClient.shared().chatManager.removeReaction(reactionsDataset[index].reaction, fromMessage: messageId, completion: { error in
            if let error = error {
                print(error.errorDescription!)
            }
            completion()
        })
    }

    func fetchReactions(messageIds: [String], completion: @escaping ReturnAction) {
        AgoraChatClient.shared().chatManager.getReactionList(messageIds, groupId: nil, chatType: .chat, completion: { reactions, error in
            if error == nil {
                self.reactions = reactions
            } else {
                print(error)
            }
            completion()
        })
    }

    func fetchReactionDetails(messageId: String, reaction: String) {
        AgoraChatClient.shared().chatManager.getReactionDetail(messageId, reaction: reaction, cursor: nil, pageSize: 30, completion: { agoraReaction, value, error in
            if let error = error {
                print(error)
            }
        })
    }
}
