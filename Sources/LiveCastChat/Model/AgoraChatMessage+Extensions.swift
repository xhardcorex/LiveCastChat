//
//  LiveCast
//
//  Created by Nik on 26.09.2022.
//

import Foundation
import AgoraChat

public extension AgoraChatMessage {
    func messageText() -> String? {
        if let messageData = (self.body as? AgoraChatTextMessageBody)?.text.data(using: .utf8) {
            let messageObject =  try? JSONDecoder().decode(ChatMessage.self, from: messageData)
            return messageObject?.text
        } else {
            return nil
        }
    }

    func messageDate() -> String? {
        ///FIXME: updated date for media messages
//        let date = Date(timeIntervalSince1970: TimeInterval(localTime)/1000)
//        return date.prettyPrinted

        if let messageData = (self.body as? AgoraChatTextMessageBody)?.text.data(using: .utf8) {
            let messageObject =  try? JSONDecoder().decode(ChatMessage.self, from: messageData)
            return messageObject?.sentDate.prettyPrinted
        } else {
            return nil
        }
    }
}
