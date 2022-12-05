//
//  ChatMessage.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 17.02.2022.
//

import Foundation

public struct ChatMessage: Codable, Equatable {
    enum CodingKeys: String, CodingKey {
        case sender, messageId, sentDate, kind, text, gifUrl, gifWidth, gifHeight
    }
    
    // MARK: Constant
    
    // MARK: Private Constant
    
    // MARK: Variable
    public var sender: SenderType = ChatMessageSender()
    public var messageId: String = ""
    public var sentDate: Date = Date()
    public var kind: MessageKind = .attributedText(NSAttributedString(string: ""))
    public var text: String = ""
    var gifExtension: GifAttachment?
    
    // MARK: Private Variable
    
    // MARK: Init
    public init(sender: SenderType,
         messageId: String = "",
         sentDate: Date = Date(),
         kind: MessageKind,
         text: String = "",
         gifExtension: GifAttachment? = nil) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
        self.text = text
        self.gifExtension = gifExtension
    }
    
    public init(with messageId: String, kind: MessageKind, sender: SenderType) {
        self.messageId = messageId
        self.kind = kind
        self.sender = sender
    }
    
    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.sender = try container.decode(ChatMessageSender.self, forKey: .sender)
            self.messageId = try container.decode(String.self, forKey: .messageId)
            
            if let sentDateString = try? container.decode(String.self, forKey: .sentDate) {
                if let date = ISO8601DateFormatter().date(from: sentDateString) {
                    self.sentDate = date
                }
            }
            
            if let kindString = try? container.decode(String.self, forKey: .kind) {
                let kind: MessageKind = try {
                    switch kindString {
                    case "attributedText", "text":
                        self.text = try container.decodeIfPresent(String.self, forKey: .text) ?? ""
                        let attrText = NSAttributedString(string: self.text)
                        return .attributedText(attrText)
                    case "gif":
                        let gifUrl = try container.decode(String.self, forKey: .gifUrl)
                        let gifWidth = try container.decode(Int.self, forKey: .gifWidth)
                        let gifHeight = try container.decode(Int.self, forKey: .gifHeight)
                        self.gifExtension = GifAttachment(gifUrl: gifUrl, gifWidth: gifWidth, gifHeight: gifHeight)
                        return .custom(gifExtension)
                    default:
                        fatalError("Not implemented")
                    }
                }()
                self.kind = kind
            }
        } catch let error as DecodingError {
            switch error {
            case .typeMismatch(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .valueNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .keyNotFound(let key, let value):
                print("error \(key), value \(value) and ERROR: \(error.localizedDescription)")
            case .dataCorrupted(let key):
                print("error \(key), and ERROR: \(error.localizedDescription)")
            default:
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let messageSender = sender as? ChatMessageSender {
            try container.encode(messageSender, forKey: .sender)
        }
        
        try container.encode(messageId, forKey: .messageId)
        try container.encode(ISO8601DateFormatter().string(from: sentDate), forKey: .sentDate)
        
        switch kind {
        case .attributedText(let text):
            try container.encode("attributedText", forKey: .kind)
            try container.encode(text.string, forKey: .text)
        case .text(let text):
            try container.encode("text", forKey: .kind)
            try container.encode(text, forKey: .text)
        case .custom(_):
            try container.encode("gif", forKey: .kind)
            try container.encode(gifExtension?.gifUrl, forKey: .gifUrl)
            try container.encode(gifExtension?.gifHeight, forKey: .gifHeight)
            try container.encode(gifExtension?.gifWidth, forKey: .gifWidth)
        default:
            assertionFailure()
        }
    }
    
    public static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

// MARK: - MessageType
extension ChatMessage: MessageType {

}
