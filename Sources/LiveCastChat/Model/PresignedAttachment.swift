//
//  PresignedAttachment.swift
//  LiveCast
//
//  Created by Игорь on 13.0122..
//

import Foundation

// MARK: - PresignedAttachment
struct PresignedAttachment: Codable {
    
    let id: String
    let subPath: String
    let presignedUrl: String
    let name: String?
    
    init(id: String, subPath: String, presignedUrl: String, name: String? = nil) {
        self.id = id
        self.subPath = subPath
        self.presignedUrl = presignedUrl
        self.name = name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        subPath = try container.decode(String.self, forKey: .subPath)
        presignedUrl = try container.decode(String.self, forKey: .presignedUrl)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(subPath, forKey: .subPath)
        try container.encode(presignedUrl, forKey: .presignedUrl)
        try container.encodeIfPresent(name, forKey: .name)
    }
}

extension PresignedAttachment {
    enum CodingKeys: String, CodingKey {
        case id, subPath, presignedUrl, name
    }
}

extension PresignedAttachment: Equatable {
    static func == (lhs: PresignedAttachment, rhs: PresignedAttachment) -> Bool {
        return lhs.id == rhs.id
    }
}
