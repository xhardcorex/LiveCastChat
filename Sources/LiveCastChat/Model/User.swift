//
//  Profile.swift
//  LiveCast
//
//  Created by Игорь on 23.1221..
//

import Foundation

public enum UserType: String {
    case regular = "REGULAR"
    case creator = "CREATOR"
}

class User: Codable, NSCopying {
    
    var id                      : Int? = nil
    var email                   : String = ""
    var username                : String = ""
    var fullName                : String? = nil
    var firstName               : String? = nil
    var lastName                : String? = nil
    var bio                     : String? = nil
    var phoneNumber             : String? = nil
    var age                     : UInt32?
    var type                    : UserType? = .regular
    var avatar                  : PresignedAttachment? = nil
    var followingNumber         : Int? = nil
    var followersNumber         : Int? = nil
    var followers               : [User] = []
    var following               : [User] = []
    var isFollowing             : Bool? = nil
    var initials                : String? = nil
    var blocked                 : Bool? = nil

    var userDataFilled  : Bool {
        return id != nil && fullName != nil && age != nil && avatar != nil
    }
    
    init(email: String, username: String) {
        self.email      = email
        self.username   = username
    }
    
    init(id: Int?, email: String, username: String, fullName: String?, firstName: String?, lastName: String?, bio: String?, phoneNumber: String?, age: UInt32?, type: UserType = .regular, avatar: PresignedAttachment?, isFollowing: Bool?, followingNumber: Int?, followersNumber: Int?) {
        self.id             = id
        self.email          = email
        self.username       = username
        self.fullName       = fullName
        self.firstName      = firstName
        self.lastName       = lastName
        self.bio            = bio
        self.phoneNumber    = phoneNumber
        self.age            = age
        self.type           = type
        self.avatar         = avatar
        self.isFollowing    = isFollowing
        self.followingNumber = followingNumber
        self.followersNumber = followersNumber
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.username = try container.decode(String.self, forKey: .username)
        self.fullName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        if let lastName = try container.decodeIfPresent(String.self, forKey: .lastName) {
            self.fullName = (firstName ?? "") + " " + lastName
        }
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.age = try container.decodeIfPresent(UInt32.self, forKey: .age)
        if let type = try container.decodeIfPresent(String.self, forKey: .type) {
            self.type = UserType(rawValue: type) ?? .regular
        }
        self.avatar = try container.decodeIfPresent(PresignedAttachment.self, forKey: .picture)
        self.isFollowing = try container.decodeIfPresent(Bool.self, forKey: .follow)
        self.followersNumber = try container.decodeIfPresent(Int.self, forKey: .followersCount)
        self.followingNumber = try container.decodeIfPresent(Int.self, forKey: .followingCount)
        self.blocked = try container.decodeIfPresent(Bool.self, forKey: .blocked)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(age, forKey: .age)
        try container.encodeIfPresent(type?.rawValue ?? "", forKey: .type)
        try container.encodeIfPresent(avatar, forKey: .picture)
        try container.encodeIfPresent(isFollowing, forKey: .follow)
        try container.encodeIfPresent(followersNumber, forKey: .followersCount)
        try container.encodeIfPresent(followingNumber, forKey: .followingCount)
    }
    
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = User(id: id, email: email, username: username, fullName: fullName, firstName: firstName, lastName: lastName, bio: bio, phoneNumber: phoneNumber, age: age, type: type ?? .regular, avatar: avatar, isFollowing: isFollowing, followingNumber: followingNumber, followersNumber: followersNumber)
        return copy
    }
    
    func isSame(to user: User) -> Bool {
        return self.id == user.id && self.email == user.email && self.bio == user.bio && self.phoneNumber == user.phoneNumber && self.avatar == user.avatar && self.fullName == user.fullName && self.firstName == user.firstName && self.lastName == user.lastName && self.age == user.age && self.username == user.username && self.avatar?.id == user.avatar?.id && self.avatar?.presignedUrl == user.avatar?.presignedUrl && self.followersNumber == user.followersNumber && self.followingNumber == user.followingNumber
    }
}

extension User {
    private enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case bio
        case firstName
        case lastName
        case phoneNumber
        case age
        case type
        case picture
        case follow
        case followersCount
        case followingCount
        case blocked
    }
}


extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        if let rhsID = lhs.id, let lhsID = rhs.id {
            return rhsID == lhsID
        } else {
            return lhs.username == rhs.username
        }
    }
}
