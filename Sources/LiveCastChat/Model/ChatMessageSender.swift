//
//  ChatMessageSender.swift
//  LiveCast
//
//  Created by vladimir.kuzomenskyi on 17.02.2022.
//

import UIKit

open class ChatMessageSender: NSObject, Codable {
    enum CodingKeys: String, CodingKey {
        case senderId, displayName, profileImageURL, initials
    }
    
    // MARK: Constant
    
    // MARK: Private Constant
    
    // MARK: Variable
    public var senderId: String
    public var displayName: String
    public var profileImageURL: URL?
    public var initials: String
    
    private (set)var avatar: Avatar? = nil
    
    // MARK: Private Variable
    
    // MARK: Init
    /// Performs initialization of ChatMessageSender object
    /// - Parameters:
    ///   - senderId: Unique string identifier for sender
    ///   - displayName: Sender name
    ///   - initials: Sender`s initials`
    ///   - profileImageURL: Imape URL for sender`s profile picture`
    public init(senderId: String = "", displayName: String = "", initials: String = "", profileImageURL: URL? = nil) {
        self.senderId = senderId
        self.displayName = displayName
        self.profileImageURL = profileImageURL
        self.initials = initials
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.senderId = try container.decode(String.self, forKey: .senderId)
        self.displayName = try container.decode(String.self, forKey: .displayName)
        if let profileImageURLString = try? container.decode(String?.self, forKey: .profileImageURL) {
            self.profileImageURL = URL(string: profileImageURLString)
        }
        self.initials = try container.decode(String.self, forKey: .initials)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(senderId, forKey: .senderId)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(profileImageURL?.absoluteString, forKey: .profileImageURL)
        try container.encode(initials, forKey: .initials)
    }
    
    // MARK: Function
    
    // MARK: Private Function
}

// MARK: - SenderType
extension ChatMessageSender: SenderType {
    
}
