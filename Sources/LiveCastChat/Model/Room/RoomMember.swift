//
//  RoomMember.swift
//  LiveCast
//
//  Created by Игорь on 25.0122..
//

import UIKit

enum RoomMemberType: String {
    case regular = "REGULAR"
    case moderator = "MODERATOR"
    case host = "HOST"
}

enum SpeakingRole: String {
    case publisher = "PUBLISHER"
    case subscriber = "SUBSCRIBER"
}

class RoomMember: Codable, NSCopying {
    
    var username                : String
    var type                    : RoomMemberType
    var speakingRole            : SpeakingRole
    var associatedUser          : User?
    var isMuted                 : Bool = false
    var isMutedByModerator      : Bool = false
    var invitedToSpeak          : Bool = false
    var requestsToSpeak         : Bool = false
    var currentVolume           : Int = 100
    
    static var placeholderMember: RoomMember {
        return RoomMember()
    }
    
    // MARK: - Init
    
    init(username: String, type: RoomMemberType, role: SpeakingRole, associatedUser: User?, isMuted: Bool, isMutedByModerator: Bool, invitedToSpeak: Bool, requestsToSpeak: Bool) {
        self.username = username
        self.type = type
        self.speakingRole = role
        self.associatedUser = associatedUser
        self.isMuted = isMuted
        self.isMutedByModerator = isMutedByModerator
        self.invitedToSpeak = invitedToSpeak
        self.requestsToSpeak = requestsToSpeak
    }
    
    required init(from decoder: Decoder) throws {
        let container               = try decoder.container(keyedBy: CodingKeys.self)
        self.username               = try container.decode(String.self, forKey: .username)
        let type                    = try container.decode(String.self, forKey: .type)
        self.type                   = RoomMemberType(rawValue: type) ?? .regular
        let speakingRole            = try container.decode(String.self, forKey: .speakingRole)
        self.speakingRole           = SpeakingRole(rawValue: speakingRole) ?? .subscriber
        self.isMuted                = try container.decode(Bool.self, forKey: .muted)
        self.isMutedByModerator     = try container.decode(Bool.self, forKey: .mutedByModerator)
        self.invitedToSpeak         = try container.decode(Bool.self, forKey: .inviteToSpeak)
        self.requestsToSpeak        = try container.decode(Bool.self, forKey: .requestToSpeak)
    }
    
    private init() {
        self.username = "Unknown"
        self.type = .regular
        self.speakingRole = .subscriber
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(speakingRole.rawValue, forKey: .speakingRole)
        try container.encode(isMuted, forKey: .muted)
        try container.encode(isMutedByModerator, forKey: .mutedByModerator)
        try container.encode(invitedToSpeak, forKey: .inviteToSpeak)
        try container.encode(requestsToSpeak, forKey: .requestToSpeak)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let member = RoomMember.init(username: username, type: type, role: speakingRole, associatedUser: associatedUser, isMuted: isMuted, isMutedByModerator: isMutedByModerator, invitedToSpeak: invitedToSpeak, requestsToSpeak: requestsToSpeak)
        return member
    }
    
}

extension RoomMember {
    private enum CodingKeys: String, CodingKey {
        case username, type, speakingRole, inviteToSpeak, requestToSpeak, muted, mutedByModerator
    }
}

extension RoomMember {
    public enum SwitchableProperty {
        case type, speakingRole, isMutedByModerator, isMuted, invitedToSpeak, requestToSpeak
    }
}


extension RoomMember: Equatable {
    static func == (lhs: RoomMember, rhs: RoomMember) -> Bool {
        return lhs.username == rhs.username
    }
}
