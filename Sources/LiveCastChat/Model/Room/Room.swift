//
//  Room.swift
//  LiveCast
//
//  Created by Игорь on 20.1221..
//

import Foundation

class Room: Codable {
    
    var id: Int
    var name: String
    var description: String?
    var hostUsername: String?
    var members: [RoomMember]? 
    var badges: [Badge] = []
    var isChatAllowed = true
    var chatId: String
    var isRoomRecording = false
    var recordings: [Recording] = []

    init(id: Int, chatId: String, name: String, description: String? = nil, members: [RoomMember] = [], badges: [Badge] = [], recordings: [Recording] = []) {
        self.id = id
        self.chatId = chatId
        self.name = name
        self.description = description
        self.members = members
        self.badges = badges
        self.recordings = recordings
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        hostUsername = try container.decodeIfPresent(String.self, forKey: .hostUsername)
        badges = try container.decode([Badge].self, forKey: .roomTags)
        chatId = try container.decode(String.self, forKey: .chatId)
        isRoomRecording = try container.decode(Bool.self, forKey: .recordStart)
        recordings = try container.decodeIfPresent([Recording].self, forKey: .recordings) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(hostUsername, forKey: .hostUsername)
        try container.encode(chatId, forKey: .chatId)
        try container.encode(isRoomRecording, forKey: .recordStart)
    }
}


extension Room {
    private enum CodingKeys: String, CodingKey {
        case id, name, description, hostUsername, chatId, recordStart, recordings
        case roomTags = "roomTags"
    }
}
